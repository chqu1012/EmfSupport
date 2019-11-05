package de.dc.javafx.xcore.workbench.emf.ui

import de.dc.fx.emf.support.file.IEmfManager
import de.dc.fx.emf.support.view.IEmfEditorPart
import java.io.File
import java.util.logging.Level
import java.util.logging.Logger
import javafx.beans.value.ChangeListener
import javafx.scene.layout.VBox
import org.eclipse.emf.common.command.CommandStackListener
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.domain.EditingDomain

abstract class EmfModelView<T> extends VBox implements CommandStackListener, ChangeListener<Object>, IEmfEditorPart<T> {
	Logger log = Logger.getLogger(EmfModelView.getSimpleName())
	protected EObject currentEObject
	protected IEmfManager<T> manager
	protected EditingDomain editingDomain

	override void save(File f) {
		manager.getFile().write(manager.getRoot(), f.getAbsolutePath())
		log.log(Level.INFO, '''Write emf model to path «f.getAbsolutePath()»''')
	}

	override T load(File file) {
		return load(file.getAbsolutePath())
	}

	def T load(String filepath) {
		var T model = manager.getFile().load(filepath)
		manager.setRoot(model)
		return model
	}

	def abstract IEmfManager<T> initEmfManager()

	def IEmfManager<T> getEmfManager() {
		if (manager === null) {
			manager = initEmfManager()
		}
		return manager
	}

	override String getExtension() {
		return manager.getFile().getExtension()
	}
}
