package de.dc.fx.emf.support.ide.dialog;
import java.util.Map;

import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.beans.BeanProperties;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.internal.resources.File;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xcore.XClassifier;
import org.eclipse.emf.ecore.xcore.impl.XPackageImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.jdt.core.IJavaElement;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.internal.core.PackageFragmentRoot;
import org.eclipse.jface.databinding.swt.WidgetProperties;
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

import de.dc.fx.emf.support.ide.model.GInput;
import de.dc.fx.emf.support.util.XcoreUtil;

public class EmfSupportStubDialog extends TitleAreaDialog {
	private DataBindingContext m_bindingContext;
	private Text textEcoreModel;
	private Text textEPackage;
	private Text textEFactory;
	private Text textBasePackage;
	
	private GInput input = new GInput();
	private Text textFileExtension;

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
							parseXcore(file);
						}
					}
				}
			}
		});
		buttonOpenEcoreModel.setText("...");
		
		Label lblBasePackage = new Label(container, SWT.NONE);
		lblBasePackage.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));
		lblBasePackage.setText("Base Package:");
		
		textBasePackage = new Text(container, SWT.BORDER);
		textBasePackage.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		new Label(container, SWT.NONE);
		
		Label lblEpackage = new Label(container, SWT.NONE);
		lblEpackage.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));
		lblEpackage.setText("EPackage:");
		
		textEPackage = new Text(container, SWT.BORDER);
		textEPackage.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Button buttonEPackage = new Button(container, SWT.NONE);
		buttonEPackage.setText("...");
		
		Label lblEfactory = new Label(container, SWT.NONE);
		lblEfactory.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));
		lblEfactory.setText("EFactory:");
		
		textEFactory = new Text(container, SWT.BORDER);
		textEFactory.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Button buttonEFactory = new Button(container, SWT.NONE);
		buttonEFactory.setText("...");
		
		Label lblFileExtension = new Label(container, SWT.NONE);
		lblFileExtension.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));
		lblFileExtension.setText("File Extension:");
		
		textFileExtension = new Text(container, SWT.BORDER);
		textFileExtension.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		new Label(container, SWT.NONE);

		return area;
	}
	
	private void parseXcore(File file) {
		java.net.URI fileURI = file.getLocationURI();

		URI uri = URI.createURI(fileURI.toString());
		input.setEcoreURI(uri);
		input.setEcorePath(file.getFullPath().toOSString());
		
		XPackageImpl xpack = XcoreUtil.parse(fileURI.toString());
		input.setBasePackage(xpack.getName());
		
		if (!xpack.getClassifiers().isEmpty()) {
			XClassifier xclass = xpack.getClassifiers().get(0);
			input.seteFactoryString(xclass.getName()+"Factory");
			input.setEpackageString(xclass.getName()+"Package");
			input.setFileExtension(xclass.getName().toLowerCase());
			
			xpack.getAnnotations().forEach(a->{
				String fileExtension = a.getDetails().get("fileExtensions");
				if (fileExtension!=null) {
					input.setFileExtension(fileExtension);
				}
			});
		}
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
		m_bindingContext = initDataBindings();
	}

	@Override
	protected Point getInitialSize() {
		return new Point(650, 488);
	}
	protected DataBindingContext initDataBindings() {
		DataBindingContext bindingContext = new DataBindingContext();
		//
		IObservableValue observeTextTextEcoreModelObserveWidget = WidgetProperties.text(SWT.Modify).observe(textEcoreModel);
		IObservableValue ecorePathInputObserveValue = BeanProperties.value("ecorePath").observe(input);
		bindingContext.bindValue(observeTextTextEcoreModelObserveWidget, ecorePathInputObserveValue, null, null);
		//
		IObservableValue observeTextTextBasePackageObserveWidget = WidgetProperties.text(SWT.Modify).observe(textBasePackage);
		IObservableValue basePackageInputObserveValue = BeanProperties.value("basePackage").observe(input);
		bindingContext.bindValue(observeTextTextBasePackageObserveWidget, basePackageInputObserveValue, null, null);
		//
		IObservableValue observeTextTextEPackageObserveWidget = WidgetProperties.text(SWT.Modify).observe(textEPackage);
		IObservableValue epackageStringInputObserveValue = BeanProperties.value("epackageString").observe(input);
		bindingContext.bindValue(observeTextTextEPackageObserveWidget, epackageStringInputObserveValue, null, null);
		//
		IObservableValue observeTextTextEFactoryObserveWidget = WidgetProperties.text(SWT.Modify).observe(textEFactory);
		IObservableValue eFactoryStringInputObserveValue = BeanProperties.value("eFactoryString").observe(input);
		bindingContext.bindValue(observeTextTextEFactoryObserveWidget, eFactoryStringInputObserveValue, null, null);
		//
		IObservableValue observeTextTextFileExtensionObserveWidget = WidgetProperties.text(SWT.Modify).observe(textFileExtension);
		IObservableValue fileExtensionInputObserveValue = BeanProperties.value("fileExtension").observe(input);
		bindingContext.bindValue(observeTextTextFileExtensionObserveWidget, fileExtensionInputObserveValue, null, null);
		//
		return bindingContext;
	}
}