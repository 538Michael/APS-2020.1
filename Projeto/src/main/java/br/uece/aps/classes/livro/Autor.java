package br.uece.aps.classes.livro;

import java.util.ArrayList;
import java.util.List;

public enum Autor {
	CLARICE("Clarice Lispector"),
	ASSIS("Machado de Assis"),
	KAFKA("Franz Kafka"),
	DRUMMOND("Carlos Drummond"),
	SHAKESPEARE("William Shakespeare"),
	ALENCAR("José de Alencar"),
	ANDRZEJ("Andrzej Sapkowski");
	
	private final String autor;
	Autor(String autor) {
		this.autor = autor;
	}
	
	public String getAutor() {
		return this.autor;
	}
	
	public static String[] getListaAutor() {
		List<String> list = new ArrayList<>();
		for(Autor it : Autor.values()) {
			list.add(it.getAutor());
		}
		return list.toArray(new String[0]);
	}
}
