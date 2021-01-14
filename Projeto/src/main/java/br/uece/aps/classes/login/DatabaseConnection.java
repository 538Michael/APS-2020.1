package br.uece.aps.classes.login;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import br.uece.aps.classes.Pessoa;
import br.uece.aps.classes.livro.Livro;
import br.uece.aps.classes.livro.Categoria;
import br.uece.aps.classes.livro.Autor;

public final class DatabaseConnection {
	
	public DatabaseConnection() {
		try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {
			System.out.println("Conexão realizada.");
			
			createTableContas(connection);
			createTableLivroS(connection);
			
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
	}
	
	private void createTableContas(Connection connection)  throws SQLException {
    	Statement statement = connection.createStatement();
	    statement.execute("CREATE TABLE IF NOT EXISTS Contas(\n" +
	    " \"cpf\" integer NOT NULL PRIMARY KEY AUTOINCREMENT,\n" +
	    " \"nome\" text,\n" +
	    " \"idade\" integer,\n" +
	    " \"senha\" text,\n" +
	    " \"email\" text,\n" +
	    " \"endereco\" text,\n" +
	    " \"admin\" integer DEFAULT 0\n" +
	    ");");
	}
    
	private void createTableLivroS(Connection connection)  throws SQLException {
		Statement statement = connection.createStatement();
        statement.execute("CREATE TABLE IF NOT EXISTS Livros(\n" +
		" id integer NOT NULL PRIMARY KEY AUTOINCREMENT,\n" +
        " titulo text,\n" +
        " preco real,\n" +
        " avaliacao real,\n" +
        " qntavaliacoes integer DEFAULT 0,\n" +
        " editora text,\n" +
        " autor text,\n" +
        " categoria text\n" +
        ");");	
	}
	
	public void adicionaLivro(Livro livro) throws SQLException {
		try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {
			PreparedStatement stmt = connection.prepareStatement("SELECT * FROM Livros WHERE titulo = " + livro.getTitulo() + ";");
			ResultSet resultSet = stmt.executeQuery();
			if(resultSet.next() == false) {
				stmt = connection.prepareStatement("INSERT INTO Livros( titulo, preco, avaliacao, qntavaliacoes, editora, autor, categoria ) VALUES (?, ?, ?, ?, ?);");
				stmt.setString(1, livro.getTitulo());
				stmt.setFloat(2, livro.getPreco());
				stmt.setFloat(3, livro.getAvaliacao());
				stmt.setInt(4, livro.getQntAvaliacoes());
				stmt.setString(5, livro.getEditora());
                for(Autor autor : livro.getAutores()) {
                	stmt.setString(6, autor.getAutor());
                	for(Categoria categoria : livro.getCategorias()) {
                		stmt.setString(7, categoria.getCategoria());
                		stmt.executeUpdate();
                	}
                }
			} else {
				System.out.println("Livro já cadastrado!");
			}
		}
	}

    public void cadastrar(Integer CPF, String Nome, Integer Idade, String Senha, String Email, String Endereco, Integer Admin){
        
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {
            
            PreparedStatement stmt = connection.prepareStatement("SELECT * FROM Contas WHERE cpf = " + CPF + ";");
            ResultSet resultSet = stmt.executeQuery();
            if(resultSet.next() == false){
                stmt = connection.prepareStatement("INSERT INTO Contas( cpf, nome, idade, senha, email, endereco, admin ) VALUES (?, ?, ?, ?, ?, ?, ?);");
                stmt.setInt(1, CPF);
                stmt.setString(2, Nome);
                stmt.setInt(3, Idade);
                stmt.setString(4, Senha);
                stmt.setString(5, Email);
                stmt.setString(6, Endereco);
                stmt.setInt(7, Admin);
                stmt.executeUpdate();
                
                
                
            }else{
                System.out.println("Erro no cadastro, um usuário com este cpf já foi cadastrado!");
            }

            
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        
    }
    
    public void login(Integer CPF, String Senha){
        
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {
            
            PreparedStatement stmt = connection.prepareStatement("SELECT * FROM Contas WHERE cpf = " + CPF + ";");
            ResultSet resultSet = stmt.executeQuery();
            if(resultSet.next() == false){
                System.out.println("Erro no login, este cpf não está cadastrado no sistema!");
            }else{
                if(resultSet.getString("Senha").equals(Senha)){
                    System.out.println("Logado com sucesso!");
                }else{
                    System.out.println("Erro no login, senha errada!");
                }
                
            }            
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        
    }
    
}
