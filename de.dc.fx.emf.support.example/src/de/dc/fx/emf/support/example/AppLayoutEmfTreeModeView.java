package de.dc.fx.emf.support.example;

import org.greenrobot.eventbus.Subscribe;

import de.dc.fx.applayout.model.AppLayout;
import de.dc.fx.applayout.model.AppLayoutPackage;
import de.dc.fx.emf.support.file.IEmfManager;
import de.dc.javafx.xcore.workbench.emf.ui.EmfTreeModelView;
import de.dc.javafx.xcore.workbench.emf.ui.di.EMFPlatform;
import de.dc.javafx.xcore.workbench.emf.ui.event.EmfCommand;
import de.dc.javafx.xcore.workbench.emf.ui.event.EventContext;
import de.dc.javafx.xcore.workbench.emf.ui.event.EventTopic;
import de.dc.javafx.xcore.workbench.emf.ui.event.IEventBroker;

public class AppLayoutEmfTreeModeView extends EmfTreeModelView<AppLayout> {
	
	public AppLayoutEmfTreeModeView() {
		// Set edit mode for several attributes
		addEditableFor(AppLayoutPackage.eINSTANCE.getBaseApp_Name());
		addEditableFor(AppLayoutPackage.eINSTANCE.getApp_Controller());

		
		EMFPlatform.getInstance(IEventBroker.class).register(this);
	}

	@Override
	public IEmfManager<AppLayout> getEmfManager() {
		if (manager==null) {
			manager = new AppLayoutEmfManager();
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
	public IEmfManager<AppLayout> initEmfManager() {
		return new AppLayoutEmfManager();
	}
}
