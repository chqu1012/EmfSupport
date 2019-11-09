package de.dc.fx.emf.support.ide.template

import de.dc.fx.emf.support.ide.model.GInput

class EmfManagerTemplate implements IGenerator{
	
	override gen(GInput input)'''
	package «input.basePackage».manager;
	
	import org.eclipse.emf.common.notify.AdapterFactory;
	import org.eclipse.emf.ecore.EFactory;
	import org.eclipse.emf.ecore.EPackage;
	
	import «input.basePackage».*;
	import «input.basePackage».provider.*;
	import de.dc.fx.emf.support.AbstractEmfManager;
	import de.dc.fx.emf.support.file.IEmfFile;
	
	public class «input.name»EmfManager extends AbstractEmfManager<«input.name»>{
	
		@Override
		public EPackage getModelPackage() {
			return «input.epackageString».eINSTANCE;
		}
	
		@Override
		public EFactory getExtendedModelFactory() {
			return «input.geteFactoryString».eINSTANCE;
		}
	
		@Override
		public IEmfFile<«input.name»> initFile() {
			return new «input.name»File();
		}
	
		@Override
		protected AdapterFactory getModelItemProviderAdapterFactory() {
			return new «input.name»ItemProviderAdapterFactory();
		}
	
		@Override
		protected AppLayout initModel() {
			return AppLayoutFactory.eINSTANCE.createAppLayout();
		}
	
	}
	'''
	
	override filename(GInput input)'''«input.name»EmfManager.java'''
	
}