package de.dc.javafx.xcore.workbench.emf.ui

import de.dc.fx.emf.support.view.IEmfEditorPart
import de.dc.javafx.xcore.workbench.emf.ui.controller.BaseEmfDetailedTreeViewController
import de.dc.javafx.xcore.workbench.emf.ui.di.EMFPlatform
import de.dc.javafx.xcore.workbench.emf.ui.event.EventContext
import de.dc.javafx.xcore.workbench.emf.ui.event.IEventBroker
import de.dc.javafx.xcore.workbench.emf.ui.util.ControlByTypeSwitch
import de.dc.javafx.xcore.workbench.emf.ui.util.EmfUtil
import java.io.File
import java.net.URL
import javafx.beans.value.ChangeListener
import javafx.beans.value.ObservableValue
import javafx.event.ActionEvent
import javafx.fxml.FXMLLoader
import javafx.scene.Node
import javafx.scene.control.Button
import javafx.scene.control.Tooltip
import javafx.scene.control.TreeItem
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.AnchorPane
import org.eclipse.emf.common.command.Command
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.command.AddCommand
import org.eclipse.emf.edit.command.CommandParameter
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.emf.edit.provider.IItemLabelProvider

abstract class EmfDetailedTreeView<T> extends BaseEmfDetailedTreeViewController implements ChangeListener<TreeItem<Object>>, IEmfEditorPart<T> {
	
	EditingDomain editingDomain
	protected EmfTreeModelView<T> treeView
	protected ControlByTypeSwitch typeFormSwitch
	protected ControlByTypeSwitch childTypeFormSwitch

	new() {
		var fxmlLoader = new FXMLLoader(class.getResource("/de/dc/javafx/xcore/workbench/emf/ui/EmfDetailedTreeView.fxml"))
		fxmlLoader.setRoot(this)
		fxmlLoader.setController(this)
		fxmlLoader.load

		treeView = initEmfModelTreeView
		treeView.treeView.selectionModel.selectedItemProperty.addListener(this)
		editingDomain = treeView.emfManager.editingDomain
		typeFormSwitch = new ControlByTypeSwitch(editingDomain)
		childTypeFormSwitch = new ControlByTypeSwitch(editingDomain)
		AnchorPane::setBottomAnchor(treeView, 0d)
		AnchorPane::setTopAnchor(treeView, 0d)
		AnchorPane::setLeftAnchor(treeView, 0d)
		AnchorPane::setRightAnchor(treeView, 0d)
		emfModelTreeViewContainer.children += treeView
	}

	def getTreeView() {
		treeView
	}

	def protected void addToToolbar(Node node) {
		toolbar.getChildren().add(node)
	}

	def protected abstract EmfTreeModelView<T> initEmfModelTreeView()

	override onAddNewValueAction(ActionEvent event) {
	}

	override onDeleteSelectionValueAction(ActionEvent event) {
	}

	override onEditValueAction(ActionEvent event) {
	}

	override changed(ObservableValue<? extends TreeItem<Object>> obs, TreeItem<Object> oldValue, TreeItem<Object> newValue) {
		clearAllFields
		if (newValue !== null) {
			var value = newValue.value
			if (value instanceof EObject) {
				var eObject = value as EObject
				initAttributeFormular(eObject)
				initChildPropertiesToolbar(eObject)
				initTableContent(newValue, value, eObject)
			}
		}
	}

	def initChildPropertiesToolbar(EObject eObject) {
		var manager = treeView.emfManager
		val collection = editingDomain.getNewChildDescriptors(eObject, null)
		childToolbar.children.clear
		for (Object object : collection) {
			if (object instanceof CommandParameter) {
				var commandParameter = (object as CommandParameter)
				val name = commandParameter.value.class.simpleName.replace("Impl", "")
				var menuText = ((manager.adapterFactory.adapt(commandParameter.value,
					typeof(IItemLabelProvider)) as IItemLabelProvider)).getText(commandParameter.value)
				var icon = ((manager.adapterFactory.adapt(commandParameter.value,
					typeof(IItemLabelProvider)) as IItemLabelProvider)).getImage(commandParameter.value)
				var button = new Button(menuText)
				button.setTooltip(new Tooltip(menuText))
				button.setGraphic(new ImageView(new Image(((icon as URL)).toExternalForm)))
				button.setOnAction([event|onAddAction(event, name, eObject)])
				childToolbar.children += button
			}
		}
	}

	def onAddAction(ActionEvent e, String name, EObject current) {
		var manager = treeView.emfManager
		var eClassifier = manager.modelPackage.getEClassifier(name)
		var obj = manager.getExtendedModelFactory().create((eClassifier as EClass))
		var id = EmfUtil::getValueByName(manager.getModelPackage(), name)
		var command = AddCommand::create(editingDomain, current, id, obj)
		command.execute
		treeView.treeView.selectionModel.selectedItem.expanded = true
		var children = treeView.treeView.selectionModel.selectedItem.children
		treeView.treeView.selectionModel.select(children.get(children.size - 1))
	}

	def initTableContent(TreeItem<Object> newValue, Object value, EObject eObject) {
		var collection = editingDomain.getNewChildDescriptors(eObject, null)
		var showTableContainer = collection.size() === 1
		tableContainer.setVisible(showTableContainer)
		if (showTableContainer) {
			var Object object = collection.iterator().next()
			if (object instanceof CommandParameter) {
				val param = object as CommandParameter
				val child = param.value as EObject
				child.eClass.EAllAttributes.forEach[ e |
					childTypeFormSwitch.currentEObject = child
					childAttributeContainer.getChildren().add(childTypeFormSwitch.doSwitch(e))
				]
				var addChildButton = new Button("Add")
				addChildButton.onAction = [e|onAddNewNode(newValue, value, param)]
				childAttributeContainer.children += addChildButton
			}
		}
	}

	def onAddNewNode(TreeItem<Object> newValue, Object value, CommandParameter param) {
		var emfManager = treeView.emfManager
		var name = param.value.class.simpleName.replace("Impl", "")
		var eClassifier = treeView.emfManager.modelPackage.getEClassifier(name)
		var obj = treeView.emfManager.extendedModelFactory.create((eClassifier as EClass))
		var id = EmfUtil::getValueByName(emfManager.modelPackage, name)
		var createdObject = emfManager.extendedModelFactory.create(obj.eClass)
		childTypeFormSwitch.setEObjectValues(createdObject)
		var command = AddCommand::create(editingDomain, value, id, createdObject)
		executeCommand(command)
		newValue.setExpanded(true)
	}

	def initAttributeFormular(EObject eObject) {
		var attributes = eObject.eClass.EAllAttributes
		attributes.forEach[ e |
			typeFormSwitch.setCurrentEObject(eObject)
			attributeContainer.children += typeFormSwitch.doSwitch(e)
		]
		eObject.eClass.EAllReferences.forEach[ref | 
			attributeContainer.children += typeFormSwitch.doSwitch(ref)
		]
		var acceptAllButton = new Button("Accept All")
		acceptAllButton.setOnAction[event|typeFormSwitch.acceptAllValues]
		attributeContainer.children += acceptAllButton
	}

	def clearAllFields() {
		typeFormSwitch.clear
		childTypeFormSwitch.clear
		attributeContainer.children.clear
		childAttributeContainer.children.clear
	}

	def executeCommand(Command command) {
		editingDomain.commandStack.execute(command)
		var value = treeView.treeView.selectionModel.selectedItem.value
		EMFPlatform::getInstance(typeof(IEventBroker)).post(new EventContext("chartfx.update", value))
	}

	override getExtension() {
		treeView.emfManager.modelPackage.name
	}

	override save(File file) {
		treeView.save(file)
	}

	override load(File file) {
		treeView.load(file)
	}
}
