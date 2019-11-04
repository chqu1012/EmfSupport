package de.dc.fx.emf.support.example;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.ecore.EFactory;
import org.eclipse.emf.ecore.EPackage;

import de.dc.fx.applayout.model.AppLayout;
import de.dc.fx.applayout.model.AppLayoutFactory;
import de.dc.fx.applayout.model.AppLayoutPackage;
import de.dc.fx.applayout.model.provider.AppLayoutItemProviderAdapterFactory;
import de.dc.fx.emf.support.AbstractEmfManager;
import de.dc.fx.emf.support.file.IEmfFile;

public class AppLayoutEmfManager extends AbstractEmfManager<AppLayout>{

	@Override
	public EPackage getModelPackage() {
		return AppLayoutPackage.eINSTANCE;
	}

	@Override
	public EFactory getExtendedModelFactory() {
		return AppLayoutFactory.eINSTANCE;
	}

	@Override
	public IEmfFile<AppLayout> initFile() {
		return new AppDesignFile();
	}

	@Override
	protected AdapterFactory getModelItemProviderAdapterFactory() {
		return new AppLayoutItemProviderAdapterFactory();
	}

	@Override
	protected AppLayout initModel() {
		return AppLayoutFactory.eINSTANCE.createAppLayout();
	}

}
