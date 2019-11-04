package de.dc.javafx.xcore.workbench.emf.ui.di;

import com.google.inject.AbstractModule;

import de.dc.fx.emf.support.event.EmfSelectionService;
import de.dc.fx.emf.support.event.IEmfSelectionService;
import de.dc.javafx.xcore.workbench.emf.ui.event.EventBroker;
import de.dc.javafx.xcore.workbench.emf.ui.event.IEventBroker;

public class EventModule extends AbstractModule {

	@Override
	protected void configure() {
		bind(IEventBroker.class).to(EventBroker.class).asEagerSingleton();
		bind(IEmfSelectionService.class).to(EmfSelectionService.class).asEagerSingleton();
	}
}
