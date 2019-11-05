package de.dc.javafx.xcore.workbench.emf.ui

import de.dc.fx.emf.support.event.IEmfSelectionService
import de.dc.fx.emf.support.file.IEmfManager
import de.dc.javafx.xcore.workbench.emf.ui.di.EMFPlatform
import de.dc.javafx.xcore.workbench.emf.ui.event.EventContext
import de.dc.javafx.xcore.workbench.emf.ui.event.EventTopic
import de.dc.javafx.xcore.workbench.emf.ui.event.IEventBroker
import de.dc.javafx.xcore.workbench.emf.ui.handler.CustomFeedbackHandler
import de.dc.javafx.xcore.workbench.emf.ui.handler.EAttributeCellEditHandler
import de.dc.javafx.xcore.workbench.emf.ui.util.EmfUtil
import java.net.URL
import java.util.ArrayList
import java.util.Collection
import java.util.EventObject
import java.util.logging.Level
import java.util.logging.Logger
import javafx.beans.value.ObservableValue
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.event.ActionEvent
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.control.ContextMenu
import javafx.scene.control.Menu
import javafx.scene.control.MenuItem
import javafx.scene.control.SelectionMode
import javafx.scene.control.TextField
import javafx.scene.control.TreeCell
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseEvent
import org.eclipse.emf.common.command.Command
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.edit.command.AddCommand
import org.eclipse.emf.edit.command.CommandParameter
import org.eclipse.emf.edit.command.CopyToClipboardCommand
import org.eclipse.emf.edit.command.DeleteCommand
import org.eclipse.emf.edit.command.PasteFromClipboardCommand
import org.eclipse.emf.edit.provider.IItemLabelProvider
import org.eclipse.fx.emf.edit.ui.AdapterFactoryTreeCellFactory
import org.eclipse.fx.emf.edit.ui.AdapterFactoryTreeItem
import org.eclipse.fx.emf.edit.ui.dnd.CellDragAdapter
import org.eclipse.fx.emf.edit.ui.dnd.EditingDomainCellDropAdapter
import javafx.stage.FileChooser
import javafx.stage.Stage

abstract class EmfTreeModelView<T> extends EmfModelView<T> {
	
	Logger log = Logger::getLogger(typeof(EmfTreeModelView).getSimpleName())
	
	@FXML protected Menu openWithMenu
	@FXML protected ContextMenu contextMenu
	@FXML protected MenuItem newMenuItem
	@FXML protected MenuItem undoMenuItem
	@FXML protected MenuItem redoMenuItem
	@FXML protected MenuItem editMenuItem
	@FXML protected MenuItem copyMenuItem
	@FXML protected MenuItem pasteMenuItem
	@FXML protected MenuItem deleteMenuItem
	@FXML protected MenuItem saveMenu
	@FXML protected MenuItem loadMenu
	@FXML protected Menu newMenu
	@FXML protected TreeView<Object> treeView
	protected ObservableList<MenuItem> defaultMenuItems = FXCollections::observableArrayList()
	protected AdapterFactoryTreeCellFactory<Object> treeCellFactory
	protected IEmfSelectionService selectionService
	protected IEventBroker eventBroker

	new() {
		var fxmlLoader = new FXMLLoader(class.getResource("/de/dc/javafx/xcore/workbench/emf/ui/EmfModelTreeView.fxml"))
		fxmlLoader.setRoot(this)
		fxmlLoader.setController(this)
		fxmlLoader.load()

		emfManager.initializeEmf
	}

	new(IEmfManager<T> manager) {
		var fxmlLoader = new FXMLLoader(class.getResource("/de/dc/javafx/efxclipse/runtime/EMFModelTreeView.fxml"))
		fxmlLoader.setRoot(this)
		fxmlLoader.setController(this)
		fxmlLoader.load

		this.manager = manager
		this.editingDomain = manager.editingDomain
		initTreeView
	}

	def initializeEmf(IEmfManager<T> manager) {
		this.manager = manager
		this.editingDomain = manager.editingDomain
		initTreeView
	}

	def onMenuItemAction(ActionEvent e){
		val source = e.source
		val chooser = new FileChooser
		if(source == saveMenu){
			val file = chooser.showSaveDialog(new Stage)
			emfManager.file.write(emfManager.root, file.absolutePath)
		}else if(source == loadMenu){
			val file = chooser.showOpenDialog(new Stage)
			val root = emfManager.file.load(file.absolutePath)
			emfManager.root = root
			initTreeView
		}
	}

	override T load(String filepath) {
		var T model = manager.file.load(filepath)
		manager.setRoot(model)
		var TreeItem<Object> rootItem = new AdapterFactoryTreeItem(manager.root, manager.adapterFactory)
		treeView.setRoot(rootItem)
		model
	}

	def initTreeView() {
		treeView.selectionModel.setSelectionMode(SelectionMode::MULTIPLE)
		treeView.selectionModel.selectedItemProperty.addListener(this)
		var TreeItem<Object> rootItem = new AdapterFactoryTreeItem(manager.getRoot(), manager.adapterFactory)
		treeView.setRoot(rootItem)
		treeCellFactory = new AdapterFactoryTreeCellFactory(manager.adapterFactory)
		// adds drag support
		treeCellFactory.addCellCreationListener(new CellDragAdapter)
		// adds drop support
		var dropAdapter = new EditingDomainCellDropAdapter(manager.editingDomain)
		dropAdapter.setFeedbackHandler(new CustomFeedbackHandler)
		treeCellFactory.addCellCreationListener(dropAdapter)
		treeView.setCellFactory(treeCellFactory)
		rootItem.setExpanded(true)
		treeView.setEditable(false)
		treeView.setOnKeyPressed[event|onTreeViewKeyPressed(event)]
		selectionService = EMFPlatform::getInstance(typeof(IEmfSelectionService))
		eventBroker = EMFPlatform::getInstance(typeof(IEventBroker))
		selectionService.registerProvider(treeView.selectionModel.selectedItemProperty, emfManager)
	}

	def onTreeViewKeyPressed(KeyEvent event) {
		if (event.code === KeyCode::F2) {
			activateEditModeForSelection
		}
		onTreeKeyBinding(event.code)
	}

	def onTreeKeyBinding(KeyCode code) {
	}

	def activateEditModeForSelection() {
		val selectedItem = treeView.selectionModel.selectedItem
		treeView.setEditable(true)
		treeView.edit(selectedItem)
		var cells = #[treeView.lookupAll(".tree-cell")]
		var row = treeView.getRow(selectedItem)
		val cell = (cells.get(row) as TreeCell<Object>)
		var graphic = cell.graphic
		if (graphic instanceof TextField) {
			var textfield = graphic as TextField
			textfield.setOnKeyPressed[ e |
				if (e.code === KeyCode::ENTER) {
					cell.commitEdit(selectedItem.value)
				}
			]
			textfield.requestFocus
			textfield.selectAll
		}
	}

	/** 
	 * EAttributes can get from EPackage#get[ItemName]_[AttributeName]()
	 * @param attribute
	 */
	def addEditableFor(EAttribute attribute) {
		// add edit support
		treeCellFactory.addCellEditHandler(new EAttributeCellEditHandler(attribute, editingDomain))
	}

	@FXML def onUndoMenuItemClicked(ActionEvent event) {
		if (editingDomain.commandStack.canUndo) {
			editingDomain.commandStack.undo
		}
	}

	@FXML def onRedoMenuItemClicked(ActionEvent event) {
		if (editingDomain.commandStack.canRedo) {
			editingDomain.commandStack.redo
		}
	}

	def execute(Command command, Collection<Object> collection) {
		if (command.canExecute) {
			command.execute
			var action = command.label
			var size = String::valueOf(collection.size)
			log.log(Level::INFO, "{0} {1} selection(s).", (#[action, size] as String[])) // TODO: not refactored yet!
			// eventBroker.post(new EventContext<>(EventTopic.COMMAND_STACK_REFRESH,
			// CommandFactory.create(command, action, action + " " + size + " selection(s)")));
		}
	}

	@FXML def onDeleteMenuItemClicked(ActionEvent event) {
		var selections = treeView.selectionModel.selectedItems
		var toDeleteList = selections.map[e|e.value]
		var command = DeleteCommand::create(editingDomain, toDeleteList)
		execute(command, toDeleteList)
	}

	@FXML def onEditMenuItemClicked(ActionEvent event) {
		activateEditModeForSelection
	}

	@FXML def onCopyMenuItemClicked(ActionEvent event) {
		var collection = new ArrayList
		collection.add(treeView.selectionModel.selectedItem.value)
		var command = CopyToClipboardCommand::create(editingDomain, collection)
		execute(command, collection)
	}

	@FXML def onPasteMenuItemClicked(ActionEvent event) {
		var selectedItem = treeView.selectionModel.selectedItem
		var selection = selectedItem.value
		var command = PasteFromClipboardCommand::create(editingDomain, selection, CommandParameter::NO_INDEX)
		if (command.canExecute) {
			command.execute()
			// TODO: not refactored yet!
			// eventBroker.post(new EventContext<>(EventTopic.COMMAND_STACK_REFRESH,
			// CommandFactory.create(command, "Paste", "Paste selection to clipboard")));
			selectedItem.setExpanded(true)
		}
	}

	@FXML def onTreeViewMouseClicked(MouseEvent event) {
		var selection = treeView.selectionModel.selectedItem
		if (treeView.isEditable) {
			treeView.setEditable(false)
		}
		if (selection !== null) {
			EMFPlatform::getInstance(typeof(IEventBroker)).post(
				new EventContext(EventTopic::SELECTION, selection.value))
			if (event.clickCount === 2) {
				eventBroker.post(new EventContext(EventTopic::OPEN_EDITOR, selection.value))
			}
		}
	}

	override changed(ObservableValue<? extends Object> arg0, Object arg1, Object newValue) {
		if (newValue instanceof TreeItem<?>) {
			val treeItem = newValue as TreeItem<?>
			val value = treeItem.value
			newMenu.items.clear
			val collection = editingDomain.getNewChildDescriptors(value, null)
			for (Object object : collection) {
				if (object instanceof CommandParameter) {
					var commandParameter = object as CommandParameter
					val name = commandParameter.value.class.simpleName.replace("Impl", "")
					var menuText = ((manager.adapterFactory.adapt(commandParameter.value,
						typeof(IItemLabelProvider)) as IItemLabelProvider)).getText(commandParameter.value)
					var icon = ((manager.adapterFactory.adapt(commandParameter.value,
						typeof(IItemLabelProvider)) as IItemLabelProvider)).getImage(commandParameter.value)
					var item = new MenuItem(menuText)
					item.setGraphic(new ImageView(new Image(((icon as URL)).toExternalForm)))
					item.setOnAction[ event |
						var eClassifier = emfManager.modelPackage.getEClassifier(name)
						var obj = emfManager.extendedModelFactory.create((eClassifier as EClass))
						var id = EmfUtil::getValueByName(emfManager.modelPackage, name)
						var command = AddCommand::create(editingDomain, value, id, obj)
						command.execute
						// TODO: not refactored yet!
						// eventBroker.post(new EventContext<>(EventTopic.COMMAND_STACK_REFRESH, CommandFactory.create(command)));
						treeItem.setExpanded(true)
					]
					newMenu.items.add(item)
				}
			}
		}
	}

	override commandStackChanged(EventObject event) {
	}

	def clearDefaultContextMenu() {
		defaultMenuItems+=contextMenu.items
		contextMenu.items.clear
	}

	def restoreDefaultContextMenu() {
		contextMenu.items+=defaultMenuItems
	}

	def getTreeView() {
	 treeView
	}
}
