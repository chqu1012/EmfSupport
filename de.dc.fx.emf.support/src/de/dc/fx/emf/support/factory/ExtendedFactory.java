package de.dc.fx.emf.support.factory;

import org.eclipse.emf.ecore.EObject;

public interface ExtendedFactory {

	EObject create(int classifierId);
}
