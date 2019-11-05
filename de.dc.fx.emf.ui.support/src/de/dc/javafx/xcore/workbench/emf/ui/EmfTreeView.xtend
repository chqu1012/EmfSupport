package de.dc.javafx.xcore.workbench.emf.ui

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.fx.emf.edit.ui.AdapterFactoryTreeCellFactory
import org.eclipse.fx.emf.edit.ui.AdapterFactoryTreeItem
import org.eclipse.fx.emf.edit.ui.EAttributeCellEditHandler
import org.eclipse.fx.emf.edit.ui.dnd.CellDragAdapter
import org.eclipse.fx.emf.edit.ui.dnd.EditingDomainCellDropAdapter
import de.dc.fx.emf.support.file.IEmfManager
import de.dc.javafx.xcore.workbench.emf.ui.handler.CustomFeedbackHandler
import javafx.scene.control.SelectionMode
import javafx.scene.control.TreeView

class EmfTreeView<T> extends TreeView<Object> {
	protected EditingDomain editingDomain
	protected IEmfManager<T> manager
	protected AdapterFactoryTreeCellFactory<Object> treeCellFactory

	new(IEmfManager<T> manager) {
		this.manager = manager
		this.editingDomain = manager.getEditingDomain()
		setRoot(new AdapterFactoryTreeItem<Object>(manager.root, manager.adapterFactory))
		treeCellFactory = new AdapterFactoryTreeCellFactory(manager.adapterFactory)
		// adds drag support
		treeCellFactory.addCellCreationListener(new CellDragAdapter)
		// adds drop support
		var dropAdapter = new EditingDomainCellDropAdapter(editingDomain)
		dropAdapter.setFeedbackHandler(new CustomFeedbackHandler)
		treeCellFactory.addCellCreationListener(dropAdapter)
		cellFactory = treeCellFactory
		showRoot = false
		selectionModel.setSelectionMode = SelectionMode.MULTIPLE
		editable = true
	}

	def void addEditableFor(EAttribute attribute) {
		// add edit support
		treeCellFactory.addCellEditHandler(new EAttributeCellEditHandler(attribute, editingDomain))
	}
}
