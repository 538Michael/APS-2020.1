package br.uece.aps.classes.livro;

import java.util.ArrayList;
import java.util.List;

public enum Editora {
	COMPANHIAlETRAS("Companhia das Letras"),
	ROCCO("Editora Rocco"),
	ARQUEIRO("Editora Arqueiro"),
	INTRINSECA("Editora Intrínseca"),
	RECORD("Editora Record"),
	DRACO("Draco"),
	GENTE("Gente");
	
	public final String editora;
	Editora(String editora) {
		this.editora = editora;
	}
	
	public String getEditora() {
		return this.editora;
	}
	
	public static String[] getListaEditora() {
		List<String> list = new ArrayList<>();
		for(Editora it : Editora.values()) {
			list.add(it.getEditora());
		}
		return list.toArray(new String[0]);
	}
}
