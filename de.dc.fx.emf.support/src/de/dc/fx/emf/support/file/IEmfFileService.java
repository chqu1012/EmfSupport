package de.dc.fx.emf.support.file;

import java.io.File;

public interface IEmfFileService<T> {

	void save(File file);
	
	T load(File file);
	
	String getExtension();
}
