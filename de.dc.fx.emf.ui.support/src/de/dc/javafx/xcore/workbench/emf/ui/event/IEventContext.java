package de.dc.javafx.xcore.workbench.emf.ui.event;

public interface IEventContext<T> {

	EventTopic getEventTopic();
	
	String getEventId();
	
	T getInput();
}
