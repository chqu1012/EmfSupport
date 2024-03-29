package de.dc.fx.emf.support.event;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import de.dc.fx.emf.support.file.IEmfManager;
import javafx.beans.property.ReadOnlyObjectProperty;
import javafx.beans.value.ChangeListener;

public class EmfSelectionService implements IEmfSelectionService {

	protected IEmfManager<?> manager;

	protected List<ReadOnlyObjectProperty<?>> providers = new ArrayList<>();
	protected List<ChangeListener<?>> listeners = new ArrayList<>();
	protected ReadOnlyObjectProperty<?> focusedProvider;
	
	@Override
	public void addListener(ChangeListener listener) {
		for (ReadOnlyObjectProperty<?> provider : providers) {
			provider.addListener(listener);
		}
		listeners.add(listener);
	}

	@Override
	public void registerProvider(ReadOnlyObjectProperty provider) {
		providers.add(provider);
		provider.addListener(e->setFocusedProvider(provider));		
		listeners.forEach(e->provider.addListener(e));
	}

	@Override
	public void removeListener(ChangeListener listener) {
		for (ReadOnlyObjectProperty<?> provider : providers) {
			provider.removeListener(listener);
		}
	}

	@Override
	public void unregisterProvider(ReadOnlyObjectProperty provider) {
		providers.remove(provider);		
	}

	@Override
	public void setFocusedProvider(ReadOnlyObjectProperty provider) {
		this.focusedProvider = provider;
	}

	@Override
	public Optional<?> getSelection() {
		return Optional.of(focusedProvider.get());
	}
	
	@Override
	public void registerProvider(ReadOnlyObjectProperty<?> provider, IEmfManager<?> manager) {
		this.manager=manager;
		registerProvider(provider);
	}

	@Override
	public Optional<? extends IEmfManager<?>> getEmfManager() {
		return Optional.of(manager);
	}
}
