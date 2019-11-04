package de.dc.fx.emf.support.command;

import java.util.List;

import org.eclipse.emf.common.command.BasicCommandStack;
import org.eclipse.emf.common.command.Command;

public class CommandStackImpl extends BasicCommandStack {
	
	public List<Command> getCommandList() {
		return commandList; 
	}

	public int getTop() {
		return top;
	}
}