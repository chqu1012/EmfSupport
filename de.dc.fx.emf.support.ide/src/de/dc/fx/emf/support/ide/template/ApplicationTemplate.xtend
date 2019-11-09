package de.dc.fx.emf.support.ide.template

import de.dc.fx.emf.support.ide.model.GInput

class ApplicationTemplate implements IGenerator{
	
	override gen(GInput input)'''
	package «input.basePackage»;
	
	import de.dc.javafx.xcore.workbench.emf.ui.di.EMFPlatform;
	import javafx.application.Application;
	import javafx.scene.Scene;
	import javafx.stage.Stage;
	
	public class «input.name»Application extends Application{
	
		@Override
		public void start(Stage primaryStage) throws Exception {
			primaryStage.setScene(new Scene(new «input.name»DetailedEmfTreeView()));
			primaryStage.show();
		}
		
		public static void main(String[] args) {
			EMFPlatform.init();
			launch(args);
		}
	
	}
	'''
	
	override filename(GInput t) '''«t.name»Application.java'''
	
}