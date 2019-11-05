package de.dc.javafx.xcore.workbench.emf.ui

import java.io.File
import java.util.logging.Level
import java.util.logging.Logger
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.emf.edit.provider.ComposedAdapterFactory
import org.eclipse.fx.emf.edit.ui.AdapterFactoryListCellFactory
import org.eclipse.fx.emf.edit.ui.AdapterFactoryObservableList
import org.eclipse.fx.emf.edit.ui.EAttributeCellEditHandler
import org.eclipse.fx.emf.edit.ui.dnd.CellDragAdapter
import org.eclipse.fx.emf.edit.ui.dnd.EditingDomainCellDropAdapter
import de.dc.fx.emf.support.file.IEmfManager
import de.dc.javafx.xcore.workbench.emf.ui.handler.CustomFeedbackHandler
import javafx.scene.control.ListView
import javafx.scene.control.SelectionMode

abstract class EmfListView<T> extends ListView<T> {
	Logger log = Logger.getLogger(EmfListView.getSimpleName())
	protected IEmfManager<T> manager
	protected EditingDomain editingDomain
	protected ComposedAdapterFactory adapterFactory
	AdapterFactoryListCellFactory<T> listCellFactory

	new() {
		this.manager = initEmfManager()
		this.adapterFactory = manager.getAdapterFactory()
		this.editingDomain = manager.getEditingDomain()
		setEditable(true)
		setItems(new AdapterFactoryObservableList<T>(adapterFactory, manager.getRoot()))
		listCellFactory = new AdapterFactoryListCellFactory(adapterFactory)
		listCellFactory.addCellCreationListener(new CellDragAdapter())
		var dropAdapter = new EditingDomainCellDropAdapter(editingDomain)
		dropAdapter.setFeedbackHandler(new CustomFeedbackHandler)
		listCellFactory.addCellCreationListener(dropAdapter)
		setCellFactory(listCellFactory)
		// add edit support
		setEditable(true)
		getSelectionModel.setSelectionMode(SelectionMode.MULTIPLE)
	}

	def void setInput(T input) {
		manager.setRoot(input)
		setItems(new AdapterFactoryObservableList<T>(adapterFactory, manager.getRoot()))
	}

	def void addEditableFor(EAttribute attribute) {
		listCellFactory.addCellEditHandler(new EAttributeCellEditHandler(attribute, editingDomain))
	}

	def abstract IEmfManager<T> initEmfManager()

	def IEmfManager<T> getEmfManager() {
		return manager
	}

	def void save(File f) {
		manager.getFile().write(manager.getRoot(), f.getAbsolutePath())
		log.log(Level.INFO, '''Write emf model to path «f.getAbsolutePath()»''')
	}

	def T load(File file) {
		return load(file.getAbsolutePath())
	}

	def T load(String filepath) {
		var T model = manager.getFile().load(filepath)
		manager.setRoot(model)
		return model
	}
}
