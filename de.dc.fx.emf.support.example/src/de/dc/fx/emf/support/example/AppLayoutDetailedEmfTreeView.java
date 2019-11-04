package de.dc.fx.emf.support.example;

import de.dc.fx.applayout.model.AppLayout;
import de.dc.javafx.xcore.workbench.emf.ui.EmfDetailedTreeView;
import de.dc.javafx.xcore.workbench.emf.ui.EmfTreeModelView;

public class AppLayoutDetailedEmfTreeView extends EmfDetailedTreeView<AppLayout>{

	@Override
	protected EmfTreeModelView<AppLayout> initEmfModelTreeView() {
		return new AppLayoutEmfTreeModeView();
	}

}
