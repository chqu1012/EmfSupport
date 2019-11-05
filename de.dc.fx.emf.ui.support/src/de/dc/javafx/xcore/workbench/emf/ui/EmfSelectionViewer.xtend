package de.dc.javafx.xcore.workbench.emf.ui

import java.lang.reflect.Field
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import java.lang.reflect.Modifier
import java.util.ArrayList
import java.util.Arrays
import java.util.List
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl
import de.dc.fx.emf.support.event.IEmfSelectionService
import de.dc.javafx.xcore.workbench.emf.ui.di.EMFPlatform
import de.dc.javafx.xcore.workbench.emf.ui.selection.SelectionProperty
import de.dc.javafx.xcore.workbench.emf.ui.selection.SelectionViewer
import javafx.beans.value.ChangeListener
import javafx.beans.value.ObservableValue
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.collections.transformation.FilteredList
import javafx.scene.control.TreeItem
import javafx.scene.control.cell.PropertyValueFactory
import javafx.scene.control.cell.TreeItemPropertyValueFactory
import javafx.scene.image.Image
import javafx.scene.image.ImageView

class EmfSelectionViewer extends SelectionViewer implements ChangeListener<Object> {
	
	public static final String ID = "de.dc.javafx.xcore.workbench.emf.ui.EmfSelectionViewer"
	
	ObservableList<SelectionProperty> attributeProperties = FXCollections::observableArrayList()
	ObservableList<SelectionProperty> methodsProperties = FXCollections::observableArrayList()
	FilteredList<SelectionProperty> fitleredAttributeProperties = new FilteredList(attributeProperties, [p|true])
	FilteredList<SelectionProperty> fitleredMethodsProperties = new FilteredList(methodsProperties, [p|true])
	
	static final Image classIcon = new Image(typeof(EmfSelectionViewer).getResourceAsStream("/de/dc/javafx/xcore/workbench/emf/ui/icons/class_obj.png"))
	static final Image methodIcon = new Image(typeof(EmfSelectionViewer).getResourceAsStream("/de/dc/javafx/xcore/workbench/emf/ui/icons/methpub_obj.png"))
	static final Image interfaceIcon = new Image(typeof(EmfSelectionViewer).getResourceAsStream("/de/dc/javafx/xcore/workbench/emf/ui/icons/int_obj.png"))
	static final Image publicFieldIcon = new Image(typeof(EmfSelectionViewer).getResourceAsStream("/de/dc/javafx/xcore/workbench/emf/ui/icons/field_public_obj.png"))
	static final Image privateFieldIcon = new Image(typeof(EmfSelectionViewer).getResourceAsStream("/de/dc/javafx/xcore/workbench/emf/ui/icons/field_private_obj.png"))
	static final Image protectedFieldIcon = new Image(typeof(EmfSelectionViewer).getResourceAsStream("/de/dc/javafx/xcore/workbench/emf/ui/icons/field_protected_obj.png"))
	TreeItem<SelectionProperty> root = new TreeItem()

	new() {
		EMFPlatform::getInstance(typeof(IEmfSelectionService)).addListener(this)
		attributeNameColumn.setCellValueFactory(new PropertyValueFactory<SelectionProperty, String>("name"))
		attributeValueColumn.setCellValueFactory(new PropertyValueFactory<SelectionProperty, String>("value"))
		attributeTableView.setItems(fitleredAttributeProperties)
		methodNameColumn.setCellValueFactory(new PropertyValueFactory<SelectionProperty, String>("name"))
		methodValueColumn.setCellValueFactory(new PropertyValueFactory<SelectionProperty, String>("value"))
		methodTableVIew.setItems(fitleredMethodsProperties)
		typeNameColumn.setCellValueFactory(new TreeItemPropertyValueFactory<SelectionProperty, String>("name"))
		typeValueColumn.setCellValueFactory(new TreeItemPropertyValueFactory<SelectionProperty, String>("value"))
		typeTreeTableView.setRoot(root)
		showNullValuesCheckBox.selectedProperty().addListener[ observable, oldValue, newValue |
			if (newValue) {
				fitleredMethodsProperties.setPredicate([t|true])
				fitleredAttributeProperties.setPredicate([t|true])
			} else {
				fitleredMethodsProperties.setPredicate([t|!t.getValue().equals("null")])
				fitleredAttributeProperties.setPredicate([t|!t.getValue().equals("null")])
			}
		]
		searchText.textProperty().addListener[ arg0, arg1, newValue |
			fitleredAttributeProperties.setPredicate([p|p.getName().toLowerCase().contains(newValue)])
			fitleredMethodsProperties.setPredicate([p|p.getName().toLowerCase().contains(newValue)])
		]
	}

	override void changed(ObservableValue<? extends Object> observable, Object oldValue, Object newValue) {
		if (newValue instanceof TreeItem) {
			var TreeItem<?> item = (newValue as TreeItem<?>)
			var selection = item.getValue()
			selectedTypeLabel.setText(selection.getClass().getCanonicalName())
			attributeProperties.clear()
			methodsProperties.clear()
			root.getChildren().clear()
			initAttributes(item.getValue())
			initMethods(item.getValue())
			initTreeMethods(item.getValue())
		}
	}

	def private void initTreeMethods(Object newValue) {
		var SelectionProperty value = new SelectionProperty()
		value.setName(newValue.getClass().getSimpleName())
		root.setValue(value)
		root.setGraphic(new ImageView(classIcon))
		root.setExpanded(true)
		initTreeMethod(root, newValue)
	}

	def private void initTreeMethod(TreeItem<SelectionProperty> root, Object newValue) {
		var Class<?> clazz = newValue.getClass()
		addFields(root, newValue)
		addInterfaces(root, newValue)
		var TreeItem<SelectionProperty> currentParentItem = root
		while (clazz !== typeof(Object) && !clazz.isAssignableFrom(typeof(MinimalEObjectImpl))) {
			var SelectionProperty newRoot = new SelectionProperty()
			newRoot.setName(clazz.getSimpleName())
			var TreeItem<SelectionProperty> newRootItem = new TreeItem(newRoot, new ImageView(classIcon))
			newRootItem.setExpanded(true)
			currentParentItem.getChildren().add(newRootItem)
			currentParentItem = newRootItem
			addMethods(newValue, clazz, newRootItem)
			clazz = clazz.getSuperclass()
			newRoot.setName(clazz.getSimpleName())
		}
	}

	def private void addInterfaces(TreeItem<SelectionProperty> root, Object newValue) {
		for (Class<?> intferface : newValue.getClass().getInterfaces()) {
			var SelectionProperty selectionProperty = new SelectionProperty()
			selectionProperty.setName(intferface.getSimpleName())
			selectionProperty.setObject(intferface)
			var TreeItem<SelectionProperty> interfaceTreeItem = new TreeItem(selectionProperty,
				new ImageView(interfaceIcon))
			addFields(interfaceTreeItem, newValue)
			addMethods(newValue, intferface, interfaceTreeItem)
			root.getChildren().add(interfaceTreeItem)
		}
	}

	def private void addMethods(Object newValue, Class<?> object, TreeItem<SelectionProperty> objectTreeItem) {
		for (Method method : object.getDeclaredMethods()) {
			method.setAccessible(true)
			try {
				var SelectionProperty item = new SelectionProperty()
				var String name = method.getName()
				var Object value = null
				if (method.getParameterCount() === 0) {
					value = method.invoke(newValue)
				}
				item.setName('''«name»()'''.toString)
				item.setValue(String::valueOf(value))
				item.setObject(newValue)
				objectTreeItem.getChildren().add(new TreeItem<SelectionProperty>(item, new ImageView(methodIcon)))
			} catch (IllegalArgumentException | IllegalAccessException | InvocationTargetException e) {
				e.printStackTrace()
			}

		}
	}

	def private void addFields(TreeItem<SelectionProperty> root, Object newValue) {
		for (Field field : newValue.getClass().getDeclaredFields()) {
			var SelectionProperty selectionProperty = new SelectionProperty()
			selectionProperty.setName(field.getName())
			selectionProperty.setObject(field)
			var TreeItem<SelectionProperty> fieldTreeItem = new TreeItem(selectionProperty,
				new ImageView(getImageByFieldVisibility(field)))
			root.getChildren().add(fieldTreeItem)
		}
	}

	def private Image getImageByFieldVisibility(Field field) {

		switch (field.getModifiers()) {
			case Modifier::PUBLIC: {
				return publicFieldIcon
			}
			case Modifier::PRIVATE: {
				return privateFieldIcon
			}
			case Modifier::PROTECTED: {
				return protectedFieldIcon
			}
			default: {
				return publicFieldIcon
			}
		}
	}

	def private void initMethods(Object newValue) {
		var List<Method> declaredMethods = getMethods(newValue)
		for (Method method : declaredMethods) {
			method.setAccessible(true)
			try {
				var SelectionProperty item = new SelectionProperty()
				var String name = method.getName()
				var Object value = null
				if (method.getParameterCount() === 0) {
					value = method.invoke(newValue)
				}
				item.setName(name)
				item.setValue(String::valueOf(value))
				item.setObject(newValue)
				methodsProperties.add(item)
			} catch (IllegalArgumentException | IllegalAccessException | InvocationTargetException e) {
				e.printStackTrace()
			}

		}
		methodsProperties.sort([o1, o2|o1.getName().compareTo(o2.getName())])
	}

	def private void initAttributes(Object newValue) {
		var List<Field> declaredFields = getFields(newValue)
		for (Field field : declaredFields) {
			field.setAccessible(true)
			try {
				var SelectionProperty item = new SelectionProperty()
				var String name = field.getName()
				var Object value = field.get(newValue)
				item.setName(name)
				item.setValue(String::valueOf(value))
				item.setObject(newValue)
				attributeProperties.add(item)
			} catch (IllegalArgumentException | IllegalAccessException e) {
				e.printStackTrace()
			}

		}
		attributeProperties.sort([o1, o2|o1.getName().compareTo(o2.getName())])
	}

	def private <T> List<Field> getFields(T t) {
		var List<Field> fields = new ArrayList()
		var Class<?> clazz = t.getClass()
		while (clazz !== typeof(Object)) {
			fields.addAll(Arrays::asList(clazz.getDeclaredFields()))
			if (showAllSuperClassFieldsCheckBox.isSelected()) {
				clazz = clazz.getSuperclass()
			} else {
				clazz = typeof(Object)
			}
		}
		return fields
	}

	def private <T> List<Method> getMethods(T t) {
		var List<Method> methods = new ArrayList()
		var Class<?> clazz = t.getClass()
		while (clazz !== typeof(Object)) {
			methods.addAll(Arrays::asList(clazz.getDeclaredMethods()))
			if (showAllSuperClassFieldsCheckBox.isSelected()) {
				clazz = clazz.getSuperclass()
			} else {
				clazz = typeof(Object)
			}
		}
		return methods
	}
}
