package de.dc.fx.emf.support.ide.template

import de.dc.fx.emf.support.ide.model.GInput

class DetailedEmfTreeViewTemplate implements IGenerator{
	
	override filename(GInput t)'''«t.name»DetailedEmfTreeView.java'''
	
	override gen(GInput t)'''
	package «t.basePackage».view;
	
	import «t.basePackage».*;
	import de.dc.javafx.xcore.workbench.emf.ui.EmfDetailedTreeView;
	import de.dc.javafx.xcore.workbench.emf.ui.EmfTreeModelView;
	
	public class «t.name»DetailedEmfTreeView extends EmfDetailedTreeView<«t.name»>{
	
		@Override
		protected EmfTreeModelView<AppLayout> initEmfModelTreeView() {
			return new «t.name»EmfTreeModelView();
		}
	
	}
	'''
	
}