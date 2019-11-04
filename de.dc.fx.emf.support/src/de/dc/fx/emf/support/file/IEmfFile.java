package de.dc.fx.emf.support.file;

import org.eclipse.emf.ecore.EFactory;
import org.eclipse.emf.ecore.EPackage;

public interface IEmfFile<T> {

	T load(String filePath);

	void write(T model, String path);

	EPackage getEPackageEInstance();

	EFactory getEFactoryEInstance();

	String getExtension();
}
