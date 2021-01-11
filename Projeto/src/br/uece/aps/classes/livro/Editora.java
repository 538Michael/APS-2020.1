package br.uece.aps.classes.livro;

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
}
