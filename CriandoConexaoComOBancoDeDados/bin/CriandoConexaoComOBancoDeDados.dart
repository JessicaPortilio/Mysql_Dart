import 'package:CriandoConexaoComOBancoDeDados/bd.dart' as bd;

// A atualização para o sqljocky5 passou a exigir a importação da linha abaixo para o uso do MySqlConnection
import 'package:sqljocky5/connection/connection.dart';
import 'package:sqljocky5/results/results.dart';

void main() async {
  var conn = await bd.createConnection();

  await createTable(conn);
  //await insertData(conn);
  //await updateData(conn);
  //await listData(conn);
  //await removeData(conn);
  //await dropTable(conn);
  // Comentei a linha do close por estar gerando  erro e impedindo a inserção dos dados no banco de dados após a atualização do sqljocky5 para a versão 2.2.1 que mudou os Statements.
  //    Unhandled exception:
  //    Bad state: Cannot write to socket, it is closed
  var trans = await conn.begin();

  try {

    await trans.execute('insert into people (id, name, email, age) values (1, "Leonardo", "leo@leo.com", 23)');
    await trans.execute('insert into horse (person_id) values (1)');
    await trans.commit();

  } catch(e) {

    print(e);
    await trans.rollback();
  }

  await conn.close();
}
Future<void> createTables(MySqlConnection conn) async {
  await conn.execute('CREATE TABLE IF NOT EXISTS people (id INTEGER NOT NULL auto_increment, name VARCHAR(255), age INTEGER, email VARCHAR(255), PRIMARY KEY (id))');
  await conn.execute('CREATE TABLE IF NOT EXISTS horse (id INTEGER NOT NULL auto_increment, person_id INTEGER NOT NULL, PRIMARY KEY (id), FOREIGN KEY (person_id) REFERENCES people(id))');
}

Future<void> dropTable(MySqlConnection conn) async {
  print('\nRemovendo tabela...');

  await conn.execute('DROP TABLE people');
}


Future<void> removeData(MySqlConnection conn) async {
  print('\nRemovendo dados...');

  await conn.execute('DELETE FROM people');
}

Future<void> updateData(MySqlConnection conn) async {
  print('\n\nAtualizando dados...');

  await conn.prepared('UPDATE people SET name = ? where id = ?', ['Leonardo', 1]);
}

Future<void> listData(MySqlConnection conn) async {
  print('Listando dados');

  StreamedResults results = await conn.execute('SELECT * FROM people');
  results.forEach((Row row) => print('ID: ${row[0]}, Nome: ${row[1]}, Idade: ${row[2]}, Email: ${row[3]},'));
}

Future<void> createTable(MySqlConnection conn) async {
  print('Criando tabelas');
  await conn.execute('CREATE TABLE IF NOT EXISTS people (id INTEGER NOT NULL auto_increment, name VARCHAR(255), age INTEGER, email VARCHAR(255), PRIMARY KEY (id))');
}

Future<void> insertData(MySqlConnection conn) async {
  print("Inserindo dados ...");

  var data = [
    ['Leonardo', 'leo@leo.com', 23],
    ['Tella', 'tella@tella.com', 20],
    ['Gaby', 'gaby@gaby.com', 20],
  ];

  // Na versão utilizada na aula (2.2.0) o nome do comando era prepareMulti, agora, o correto é preparedWithAll
  await conn.preparedWithAll("INSERT INTO people (name, email, age) VALUES (?, ?, ?)", data);
}