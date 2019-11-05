package de.dc.javafx.xcore.workbench.emf.ui.util;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.common.command.Command;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.Enumerator;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EEnumLiteral;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.util.EcoreSwitch;
import org.eclipse.emf.edit.command.SetCommand;
import org.eclipse.emf.edit.domain.EditingDomain;

import javafx.beans.value.ChangeListener;
import javafx.collections.FXCollections;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Control;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Region;
import javafx.scene.layout.VBox;

public class ControlByTypeSwitch extends EcoreSwitch<Region> {

	private Boolean[] booleanValues = new Boolean[] { true, false };

	private EObject currentEObject;

	private EditingDomain editingDomain;

	private Map<EAttribute, TextField> eattributeUIMap = new HashMap<>();
	private static final String EDITED_STYLE = "-fx-background-color: red; -fx-text-fill: white;";
	
	public ControlByTypeSwitch(EditingDomain editingDomain) {
		this.editingDomain = editingDomain;
	}

	@Override
	public Region caseEReference(EReference object) {
		VBox vbox = new VBox(5);
		ListView listView = new ListView<>();
		listView.setPrefHeight(100);
		
		vbox.getChildren().add(new Label(object.getName()));
		vbox.getChildren().add(listView);
		
		return vbox;
	}
	
	@Override
	public Region caseEAttribute(EAttribute eAttribue) {
		EClassifier eType = eAttribue.getEType();
		if (eType.getName().toLowerCase().equals("boolean")) {
			createComboBox(eAttribue);
		}
		
		HBox hbox = new HBox(5.0);
		Label label = new Label(eAttribue.getName());
		label.setPrefWidth(100);
		hbox.getChildren().add(label);

		if (eAttribue.getEType().getName().equals("EBoolean")) {
			hbox.getChildren().add(createComboBox(eAttribue));
		} else if (eAttribue.getEType() instanceof EEnum) {
			hbox.getChildren().add(createEnumComboBox(eAttribue));
		} else {
			createContentTextField(eAttribue, hbox);
		}

		return hbox;
	}
	
	public void setEObjectValues(EObject createdObject) {
		eattributeUIMap.entrySet().forEach(ks -> {
			Control control = ks.getValue();
			if (control.getStyle().equals(EDITED_STYLE)) {
				EAttribute key = ks.getKey();
				String eType = key.getEType().getName();
				if (eType.contains("Double")) {
					initTextField(createdObject, control, key);
				}else if (eType.contains("Boolean") || eType.contains("boolean")) {
					ComboBox<Boolean> comboBox = (ComboBox<Boolean>) control;
					createdObject.eSet(key, comboBox.getValue());
				} else {
					initTextField(createdObject, control, key);
				}
			}
		});
	}

	private void initTextField(EObject createdObject, Control control, EAttribute key) {
		TextField textField = (TextField)control;
		String content = textField.getText();
		createdObject.eSet(key, content);
		textField.setText("");
		textField.setStyle(null);
	}

	public void acceptAllValues() {
		eattributeUIMap.entrySet().stream().forEach(e -> {
			if (e.getValue().getStyle().equals(EDITED_STYLE)) {
				setValue(currentEObject, e.getKey(), e.getValue());
			}
		});
	}
	
	private void createContentTextField(EAttribute eAttribute, HBox hbox) {
		Button acceptButton = new Button("Accept");
		String stringValue = currentEObject.eGet(eAttribute) == null ? "" : currentEObject.eGet(eAttribute).toString();
		TextField textField = new TextField(stringValue);
		textField.setOnKeyPressed(event -> {
			KeyCode code = event.getCode();
			switch (code) {
			case ENTER:
				setValue(currentEObject, eAttribute, textField);
				break;
			default:
				textField.setStyle(EDITED_STYLE);
			}
		});
		acceptButton.setOnAction(event -> setValue(currentEObject, eAttribute, textField));

		eattributeUIMap.put(eAttribute, textField);
		hbox.getChildren().add(textField);
		hbox.getChildren().add(acceptButton);
	}
	
	private void setValue(EObject eObject, EAttribute eAttribute, TextField textField) {
		Command command = null;
		if (eAttribute.getEType().getName().contains("Double")) {
			command = new SetCommand(editingDomain, eObject, eAttribute, Double.parseDouble(textField.getText()));
		} else if (eAttribute.getEType().getName().contains("Integer")
				|| eAttribute.getEType().getName().contains("Int")) {
			command = new SetCommand(editingDomain, eObject, eAttribute, Integer.parseInt(textField.getText()));
		} else {
			command = new SetCommand(editingDomain, eObject, eAttribute, textField.getText());
		}
		editingDomain.getCommandStack().execute(command);
		textField.setStyle(null);
	}
	
	private ComboBox<Enumerator> createEnumComboBox(EAttribute eAttribute) {
		EEnum enumeration = (EEnum) eAttribute.getEAttributeType();
		EList<EEnumLiteral> literals = enumeration.getELiterals();

		Object currentSelection = currentEObject.eGet(eAttribute) == null ? literals.get(0) : currentEObject.eGet(eAttribute);
		EEnumLiteral selectedLiteral = enumeration.getEEnumLiteralByLiteral(String.valueOf(currentSelection));

		ComboBox<Enumerator> enumCombo = new ComboBox<>(FXCollections.observableArrayList(literals));
		enumCombo.getSelectionModel().select(selectedLiteral.getInstance());
		enumCombo.getSelectionModel().selectedItemProperty()
				.addListener((ChangeListener<Enumerator>) (observable1, oldValue1, newValue1) -> {
					Enumerator selection = enumCombo.getSelectionModel().getSelectedItem();
					EEnumLiteral enumLiteral = enumeration.getEEnumLiteral(selection.getName());
					Command command = new SetCommand(editingDomain, currentEObject, eAttribute,
							enumLiteral.getInstance());
					editingDomain.getCommandStack().execute(command);
				});

		return enumCombo;
	}

	private ComboBox<Boolean> createComboBox(EAttribute object) {
		Boolean booleanValueBoolean = false;
		try {
			booleanValueBoolean = currentEObject.eGet(object) == null ? true
					: (boolean) currentEObject.eGet(object);
		} catch (Exception e) {
			booleanValueBoolean = ((Integer) currentEObject.eGet(object)) == 0;
		}

		ComboBox<Boolean> comboBox = new ComboBox<>();
		comboBox.setItems(FXCollections.observableArrayList(booleanValues));
		comboBox.setMinWidth(100);
		comboBox.getSelectionModel().select(booleanValueBoolean);
		comboBox.getSelectionModel().selectedItemProperty()
				.addListener((obs, oldValue, newValue) -> onBooleanComboChanged(object, comboBox));
		
		return comboBox;
	}

	private void onBooleanComboChanged(EAttribute object, ComboBox<Boolean> comboBox) {
		Boolean selection = comboBox.getSelectionModel().getSelectedItem();
		Command command = new SetCommand(editingDomain, currentEObject, object, selection);
		editingDomain.getCommandStack().execute(command);
	}

	public void setCurrentEObject(EObject currentEObject) {
		this.currentEObject = currentEObject;
	}

	public Map<EAttribute, TextField> getEattributeUIMap() {
		return eattributeUIMap;
	}

	public void clear() {
		eattributeUIMap.clear();
	}
}