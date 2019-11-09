package de.dc.fx.emf.support.ide.template

import de.dc.fx.emf.support.ide.model.GInput

class EmfTreeModelViewTemplate implements IGenerator{
	
	override filename(GInput t)'''«t.name»EmfTreeModelView.java'''
	
	override gen(GInput t)'''
	package «t.basePackage».view;
	
	import org.greenrobot.eventbus.Subscribe;
	
	import «t.basePackage».*;
	import «t.basePackage».manager.*;
	import de.dc.fx.emf.support.file.IEmfManager;
	import de.dc.javafx.xcore.workbench.emf.ui.EmfTreeModelView;
	import de.dc.javafx.xcore.workbench.emf.ui.di.EMFPlatform;
	import de.dc.javafx.xcore.workbench.emf.ui.event.EmfCommand;
	import de.dc.javafx.xcore.workbench.emf.ui.event.EventContext;
	import de.dc.javafx.xcore.workbench.emf.ui.event.EventTopic;
	import de.dc.javafx.xcore.workbench.emf.ui.event.IEventBroker;
	
	public class «t.name»EmfTreeModelView extends EmfTreeModelView<«t.name»> {
		
		public «t.name»EmfTreeModelView() {
			// Set edit mode for several attributes
			// addEditableFor(«t.name»Package.eINSTANCE.getName());
	
			
			EMFPlatform.getInstance(IEventBroker.class).register(this);
		}
	
		@Override
		public IEmfManager<«t.name»> getEmfManager() {
			if (manager==null) {
				manager = new «t.name»EmfManager();
			}
			return manager;
		}
	
		@Subscribe
		public void updateViewByEventBroker(EventContext<EmfCommand> context) {
			if (context.getEventTopic()==EventTopic.COMMAND_STACK_REFRESH) {
				if (context.getInput() instanceof EmfCommand) {
	//				manager.getRoot().getValues().add(context.getInput());
				}
			}
		}
		
		@Override
		public IEmfManager<«t.name»> initEmfManager() {
			return new «t.name»EmfManager();
		}
	}
	'''
	
}