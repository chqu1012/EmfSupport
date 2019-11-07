package de.dc.fx.emf.support.ide.handler;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.swt.widgets.Shell;

import de.dc.fx.emf.support.ide.dialog.EmfSupportStubDialog;

public class GenerateStubHandler extends AbstractHandler{

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		EmfSupportStubDialog dialog = new EmfSupportStubDialog(new Shell());
		dialog.open();
		return null;
	}

}