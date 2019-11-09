package de.dc.fx.emf.support.ide.model;

import org.eclipse.emf.common.util.URI;

public class GInput extends ModelObject{

	private String name;
	private String basePackage;
	private String epackageString;
	private String eFactoryString;
	private String ecorePath;
	private URI ecoreURI;

	public String getEcorePath() {
		return ecorePath;
	}

	public void setEcorePath(String ecorePath) {
		firePropertyChange("ecorePath", this.ecorePath, this.ecorePath = ecorePath);
	}

	public String getEpackageString() {
		return epackageString;
	}

	public void setEpackageString(String epackageString) {
		firePropertyChange("epackageString", this.epackageString, this.epackageString = epackageString);
	}

	public String geteFactoryString() {
		return eFactoryString;
	}

	public void seteFactoryString(String eFactoryString) {
		firePropertyChange("eFactoryString", this.eFactoryString, this.eFactoryString = eFactoryString);
	}

	public String getBasePackage() {
		return basePackage;
	}

	public void setBasePackage(String basePackage) {
		firePropertyChange("basePackage", this.basePackage, this.basePackage = basePackage);
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public URI getEcoreURI() {
		return ecoreURI;
	}

	public void setEcoreURI(URI ecoreURI) {
		firePropertyChange("ecoreURI", this.ecoreURI, this.ecoreURI = ecoreURI);
	}
}
