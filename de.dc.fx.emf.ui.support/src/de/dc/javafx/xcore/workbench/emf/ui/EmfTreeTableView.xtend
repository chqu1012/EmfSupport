/** 
 * Copyright (c) 2013 TESIS DYNAware GmbH and others. 
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Eclipse Public License v1.0 
 * which accompanies this distribution, and is available at 
 * http://www.eclipse.org/legal/epl-v10.html 
 * Contributors: 
 * Torsten Sommer <torsten.sommer@tesis.de> - initial API and implementation 
 */
package de.dc.javafx.xcore.workbench.emf.ui

import org.eclipse.emf.common.notify.AdapterFactory
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.fx.emf.edit.ui.AdapterFactoryTreeItem
import org.eclipse.fx.emf.edit.ui.AdapterFactoryTreeTableCellFactory
import org.eclipse.fx.emf.edit.ui.TreeTableProxyCellValueFactory
import org.eclipse.fx.emf.edit.ui.dnd.CellDragAdapter
import org.eclipse.fx.emf.edit.ui.dnd.EditingDomainCellDropAdapter
import de.dc.fx.emf.support.file.IEmfManager
import javafx.scene.control.SelectionMode
import javafx.scene.control.TreeTableColumn
import javafx.scene.control.TreeTableView

class EmfTreeTableView<T> extends TreeTableView<Object> {
	protected EditingDomain editingDomain
	protected AdapterFactory adapterFactory

	new(IEmfManager<T> manager) {
		editingDomain = manager.editingDomain
		adapterFactory = manager.adapterFactory
		getSelectionModel().setSelectionMode(SelectionMode.MULTIPLE)
		setRoot(new AdapterFactoryTreeItem(manager.getRoot(), adapterFactory))
		setShowRoot(false)
		setEditable(true)
	}

	def TreeTableColumn<Object, Object> createColumn(String name) {
		var TreeTableColumn<Object, Object> column = new TreeTableColumn(name)
		var firstNameCellFactory = new AdapterFactoryTreeTableCellFactory(adapterFactory, 0)
		var dragAdapter = new CellDragAdapter
		var dropAdapter = new EditingDomainCellDropAdapter(editingDomain)
		firstNameCellFactory.addCellCreationListener(dragAdapter)
		firstNameCellFactory.addCellCreationListener(dropAdapter)
		column.setCellFactory(firstNameCellFactory)
		column.setSortable(false)
		column.setCellValueFactory(new TreeTableProxyCellValueFactory)
		columns+=column
		column
	}
}
