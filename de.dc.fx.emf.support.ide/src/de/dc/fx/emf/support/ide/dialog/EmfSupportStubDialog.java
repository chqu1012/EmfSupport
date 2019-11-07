package de.dc.fx.emf.support.ide.dialog;
import java.io.File;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.jdt.core.IJavaElement;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.internal.core.PackageFragmentRoot;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.dialogs.TitleAreaDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.ide.dialogs.OpenResourceDialog;

public class EmfSupportStubDialog extends TitleAreaDialog {
	private Text textEcoreModel;

	public EmfSupportStubDialog(Shell parentShell) {
		super(parentShell);
		setShellStyle(SWT.RESIZE);
	}

	@Override
	protected Control createDialogArea(Composite parent) {
		setMessage("Create all EMF Stub Classes for the selected resources.");
		setTitle("EMF Support Stub Generator");
		Composite area = (Composite) super.createDialogArea(parent);
		Composite container = new Composite(area, SWT.NONE);
		container.setLayout(new GridLayout(3, false));
		container.setLayoutData(new GridData(GridData.FILL_BOTH));
		
		Label lblEcoreModel = new Label(container, SWT.NONE);
		lblEcoreModel.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));
		lblEcoreModel.setText("Ecore Model:");
		
		textEcoreModel = new Text(container, SWT.BORDER);
		textEcoreModel.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Button buttonOpenEcoreModel = new Button(container, SWT.NONE);
		buttonOpenEcoreModel.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				IProject project = getCurrentProject();
				OpenResourceDialog dialog = new OpenResourceDialog(new Shell(), project, IResource.FILE);
				int code = dialog.open();
				if (code==0) {
					if (dialog.getResult().length==1) {
						Object result = dialog.getResult()[0];
						if (result instanceof File) {
							File file = (File) result;
							System.out.println(file.getAbsolutePath());
						}
					}
				}
			}
		});
		buttonOpenEcoreModel.setText("...");

		return area;
	}
	
	public IProject getCurrentProject() {
	    IProject project = null;
	    IWorkbenchWindow window = PlatformUI.getWorkbench()
	            .getActiveWorkbenchWindow();
	    if (window != null) {
	        ISelection iselection = window.getSelectionService().getSelection();
	        IStructuredSelection selection = (IStructuredSelection) iselection;
	        if (selection == null) {
	            return null;
	        }

	        Object firstElement = selection.getFirstElement();
	        if (firstElement instanceof IResource) {
	            project = ((IResource) firstElement).getProject();
	        } else if (firstElement instanceof PackageFragmentRoot) {
	            IJavaProject jProject = ((PackageFragmentRoot) firstElement)
	                    .getJavaProject();
	            project = jProject.getProject();
	        } else if (firstElement instanceof IJavaElement) {
	            IJavaProject jProject = ((IJavaElement) firstElement)
	                    .getJavaProject();
	            project = jProject.getProject();
	        }
	    }
	    return project;
	}

	@Override
	protected void createButtonsForButtonBar(Composite parent) {
		createButton(parent, IDialogConstants.OK_ID, IDialogConstants.OK_LABEL, true);
		createButton(parent, IDialogConstants.CANCEL_ID, IDialogConstants.CANCEL_LABEL, false);
	}

	@Override
	protected Point getInitialSize() {
		return new Point(650, 488);
	}

}