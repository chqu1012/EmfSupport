package de.dc.fx.emf.support.ide.template;

import de.dc.fx.emf.support.ide.model.GInput;

public interface IGenerator {

	String gen(GInput input);
	
	String path(GInput input);
}
