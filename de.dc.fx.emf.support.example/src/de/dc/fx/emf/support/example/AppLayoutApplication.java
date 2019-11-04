package de.dc.fx.emf.support.example;

import de.dc.javafx.xcore.workbench.emf.ui.di.EMFPlatform;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class AppLayoutApplication extends Application{

	@Override
	public void start(Stage primaryStage) throws Exception {
		primaryStage.setScene(new Scene(new AppLayoutDetailedEmfTreeView()));
		primaryStage.show();
	}
	
	public static void main(String[] args) {
		EMFPlatform.init();
		launch(args);
	}

}
