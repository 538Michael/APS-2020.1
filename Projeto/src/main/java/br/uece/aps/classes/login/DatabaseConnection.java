package br.uece.aps.classes.login;

import java.sql.*;
import br.uece.aps.classes.livro.Categoria;
import br.uece.aps.classes.livro.Autor;

public final class DatabaseConnection {
    
	private Connection connection;
	
	
	public DatabaseConnection() {
		try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {
			System.out.println("Conexão realizada.");
			this.connection = connection;	
			
			createTableContas();
			System.out.println("ok");
			createTableLivroS();
			System.out.println("ok");
			createTableCategorias();
			System.out.println("ok");
			createTableAutores();
			
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
	}
	
	private void createTableContas()  throws SQLException {
    	Statement statement = this.connection.createStatement();
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
    
	private void createTableLivroS()  throws SQLException {
		Statement statement = this.connection.createStatement();
        statement.execute("CREATE TABLE IF NOT EXISTS Livros(\n" +
        " titulo text,\n" +
        " preco real,\n" +
        " avaliacao real,\n" +
        " qntavaliacoes integer DEFAULT 0,\n" +
        " editora text\n" +
        ");");		
	}
	
    private void createTableCategorias() throws SQLException {       
    	int count = Categoria.values().length;     
    	String sql = "CREATE TABLE IF NOT EXISTS Categorias(\n";
    	for(Categoria categoria : Categoria.values()) {
    		if(--count == 0) {
    			sql += categoria.name() + " text\n";
    		} else {
    			sql += categoria.name() + " text,\n";
    		}
    	}
    	sql += ");";
    	
    	Statement statement = this.connection.createStatement();
    	statement.execute(sql.toString());
	}
	
	private void createTableAutores()  throws SQLException {    	
		int count = Autor.values().length;     
		String sql = "CREATE TABLE IF NOT EXISTS Categorias(\n";
		for(Autor autor : Autor.values()) {
			if(--count == 0) {
				sql += autor.name() + " text\n";
			} else {
				sql += autor.name() + " text,\n";
			}
		}
		sql += ");";
		
		Statement statement = this.connection.createStatement();
		statement.execute(sql.toString());
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
