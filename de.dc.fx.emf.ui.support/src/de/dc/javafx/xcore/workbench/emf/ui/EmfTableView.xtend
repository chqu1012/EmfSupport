package de.dc.javafx.xcore.workbench.emf.ui

import de.dc.fx.emf.support.file.IEmfManager
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.emf.edit.provider.ComposedAdapterFactory
import org.eclipse.fx.emf.edit.ui.AdapterFactoryObservableList
import org.eclipse.fx.emf.edit.ui.AdapterFactoryTableCellFactory
import org.eclipse.fx.emf.edit.ui.EAttributeCellEditHandler
import org.eclipse.fx.emf.edit.ui.ProxyCellValueFactory
import org.eclipse.fx.emf.edit.ui.dnd.CellDragAdapter
import org.eclipse.fx.emf.edit.ui.dnd.EditingDomainCellDropAdapter

class EmfTableView<T> extends TableView<Object> {
	protected IEmfManager<T> manager
	protected EditingDomain editingDomain
	protected ComposedAdapterFactory adapterFactory

	new(IEmfManager<T> manager) {
		this.manager = manager
		this.adapterFactory = manager.adapterFactory
		this.editingDomain = manager.editingDomain
		editable = true
		items = new AdapterFactoryObservableList(adapterFactory,manager.root)
	}

	def createColumn(String name, int columnIndex) {
		val cellFactory = new AdapterFactoryTableCellFactory(adapterFactory, columnIndex)=>[
			addCellCreationListener = new CellDragAdapter
			addCellCreationListener = new EditingDomainCellDropAdapter(editingDomain)
		]
		var column = new TableColumn<Object, Object>(name)=>[
			cellValueFactory = new ProxyCellValueFactory
			setCellFactory = cellFactory
			sortable = false
			
		]
		columns += column
		column
	}

	def setEditable(TableColumn<Object, Object> column, EAttribute modelPackageEAttribute) {
		var cellFactory = column.cellFactory as AdapterFactoryTableCellFactory<Object, Object>
		cellFactory.addCellEditHandler(new EAttributeCellEditHandler(modelPackageEAttribute, editingDomain))
	}
}
