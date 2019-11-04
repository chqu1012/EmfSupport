package de.dc.fx.emf.support.example;

import org.eclipse.emf.ecore.EFactory;
import org.eclipse.emf.ecore.EPackage;

import de.dc.fx.applayout.model.AppLayout;
import de.dc.fx.applayout.model.AppLayoutFactory;
import de.dc.fx.applayout.model.AppLayoutPackage;
import de.dc.fx.emf.support.EmfFile;

public class AppDesignFile extends EmfFile<AppLayout>{

	@Override
	public EPackage getEPackageEInstance() {
		return AppLayoutPackage.eINSTANCE;
	}

	@Override
	public EFactory getEFactoryEInstance() {
		return AppLayoutFactory.eINSTANCE;
	}

	@Override
	public String getExtension() {
		return "applayout";
	}

}
