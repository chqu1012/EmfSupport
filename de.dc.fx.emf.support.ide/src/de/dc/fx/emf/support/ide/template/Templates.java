package de.dc.fx.emf.support.ide.template;

import de.dc.fx.emf.support.ide.model.GInput;

public enum Templates {
	APPLICATION(new ApplicationTemplate(), "/"),
	FILE_TEMPLATE(new FileTemplate(), "/file/"),
	;
	
	private IGenerator template;
	private String exportPath;
	
	private Templates(IGenerator template, String exportPath) {
		this.template = template;
		this.exportPath = exportPath;
	}
	
	public String getExportPath(GInput t) {
		return exportPath+getTemplate().filename(t);
	}
	
	public IGenerator getTemplate() {
		return template;
	}
}
