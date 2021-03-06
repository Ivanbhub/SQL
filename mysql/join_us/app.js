var express = require('express');
var app = express();
var mysql = require('mysql');
var bodyParser  = require("body-parser");


app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({extended: true}));
app.use(express.static(__dirname + "/public"));

var connection = mysql.createConnection({
	host : 'localhost',
	user : 'root',
	database : 'join_us'
	

});

app.get("/", function(req,res){
	
	var q = "SELECT COUNT(*) as count FROM users";
	
	connection.query(q, function(err, results){
					 
				if (err) throw err;
				var count = results[0].count;
					  
				// res.send("We have "+ count + " users in our DB");
				res.render("home", {data: count})
					 
	 });
	

});


app.post('/register', function(req,res){
	var person = {email : req.body.email};
	
	connection.query("INSERT INTO users SET ?",person, function(err,result) {
		
		if (err) throw err;
		res.redirect("/");
					 
					 });
	
	// console.log('user email is ' + req.body.email);
});


app.get("/joke", function(req,res){
	
	res.render("joke");
});


app.listen(3000, function(){
	console.log("server running on port 3000...")
	;})