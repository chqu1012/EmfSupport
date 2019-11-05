package de.dc.javafx.xcore.workbench.emf.ui

import java.io.File
import javafx.collections.FXCollections
import javafx.scene.control.TreeItem

class FileTreeItem extends TreeItem<File> {
	new(File f) {
		super(f)
	}

	override getChildren() {
		if (isFirstTimeChildren) {
			isFirstTimeChildren = false
			super.children.setAll(buildChildren(this))
		}
		return super.children
	}

	override isLeaf() {
		if (isFirstTimeLeaf) {
			isFirstTimeLeaf = false
			var f = value
			isLeaf = f.isFile
		}
		isLeaf
	}

	def buildChildren(TreeItem<File> treeItem) {
		var f = treeItem.value
		if (f !== null && f.isDirectory) {
			var files = f.listFiles
			if (files !== null) {
				var children = FXCollections.observableArrayList
				for (File childFile : files) {
					children += new FileTreeItem(childFile)
				}
				return children
			}
		}
		return FXCollections.emptyObservableList
	}

	boolean isFirstTimeChildren = true
	boolean isFirstTimeLeaf = true
	boolean isLeaf
}
