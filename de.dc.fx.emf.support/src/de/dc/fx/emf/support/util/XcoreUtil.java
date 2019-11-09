package de.dc.fx.emf.support.util;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.plugin.EcorePlugin;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xcore.impl.XPackageImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;

public class XcoreUtil {

	public static XPackageImpl parse(String fileURIString) {
		URI uri = URI.createURI(fileURIString);
		
		try {
			Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
			Map<String, Object> m = reg.getExtensionToFactoryMap();
			m.put("*", new XMIResourceFactoryImpl());
			
			ResourceSet resourceSet = new ResourceSetImpl();
			resourceSet.getURIConverter().getURIMap().putAll(EcorePlugin.computePlatformURIMap(true));
			Resource resource = resourceSet.getResource(uri, true);
			resource.load(Collections.emptyMap());
			EObject eObject = resource.getContents().get(0);
			if (eObject instanceof XPackageImpl) {
				XPackageImpl pack = (XPackageImpl) eObject;
				return pack;
			}
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		return null;
	}
}
