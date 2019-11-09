package de.dc.fx.emf.support.ide.template

import de.dc.fx.emf.support.ide.model.GInput

class FileTemplate implements IGenerator{
	
	override gen(GInput input)'''
	package �input.basePackage�.file;
	
	import org.eclipse.emf.ecore.EFactory;
	import org.eclipse.emf.ecore.EPackage;
	
	import de.dc.fx.applayout.model.AppLayout;
	import de.dc.fx.applayout.model.AppLayoutFactory;
	import de.dc.fx.applayout.model.AppLayoutPackage;
	import de.dc.fx.emf.support.file.EmfFile;
	
	public class �input.name�File extends EmfFile<�input.name�>{
	
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
	'''
	
	override filename(GInput input)'''�input.name�.File.java'''
	
}