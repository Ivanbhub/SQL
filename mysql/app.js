var casual = require('casual');
var mysql = require('mysql');

var connection = mysql.createConnection({
	host : 'localhost',
	user : 'root',
	database : 'join_us'
});


// console.log(casual.country);
// console.log(casual.city);
// console.log(casual.date(format = 'YYYY-MM-DD'));


  // Root User: root
  //  Database Name: mysql

// var q = 'Select * from users;'
// var person = {email : casual.email,
// 			 create_at : casual.date(format = 'YYYY-MM-DD')}
// connection.query('insert into users SET ?', person, function (error,results,fields) {
	
// 	if (error) throw error;
// 	// console.log(results[0].time);
// 	// console.log(results[0].date);
// 	console.log(results);
	
// });

// connection.end();

var data = [];

for (var i = 0 ; i <500; i++){

	data.push([
	
		casual.email,
		casual.date(format = 'YYYY-MM-DD')

]);
	
}


var person = "insert into users(email, create_at) values ?"

connection.query(person,[data], function (error,results,fields) {
	
		if (error) throw error;
		console.log(error);
		console.log(results);
	
});

connection.end();