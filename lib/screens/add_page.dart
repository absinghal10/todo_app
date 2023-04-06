import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:todo_app/services/todo_services.dart';

class AddPage extends StatefulWidget {
  final Map? todo;

  const AddPage({super.key, this.todo,});
  @override 
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  bool isEdit=false;

  TextEditingController titleController=TextEditingController();
  TextEditingController descriptionController=TextEditingController();

  @override
  void initState() {

    final todo=widget.todo;
    super.initState();
    if(todo!=null){
      isEdit=true;
      final title=todo['title'];
      final description=todo['description'];
      titleController.text=title;
      descriptionController.text=description;
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit?'Edit Page':'Add Page'),
        centerTitle: true,
      ),

      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Title'
            ),
            controller: titleController,
          ),
          SizedBox(height: 20,),
          TextField(
            decoration: InputDecoration(
                hintText: 'Description'
            ),
            controller: descriptionController,
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: (){
            isEdit?UpdateData():submitData();
          }, child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                isEdit?'Update':'Submit'),
          ))
        ],
      ),

    );
  }

  Future<void> submitData() async {
    // get data from form
    // submit data to server
    // show success or fail message based on status

   final title=titleController.text;
   final description=descriptionController.text;

   final body={
       "title": title,
       "description": description,
       "is_completed": false
   };


    final url="http://api.nstack.in/v1/todos";
    final uri=Uri.parse(url);
    final response=await http.post(uri,body: jsonEncode(body),
    headers: {'Content-Type':'application/json'}
    );

    if(response.statusCode==201){
      titleController.text='';
      descriptionController.text='';
     showSuccessMessage();
    }else{
     showErrorMessage();
    }
  }


  void showSuccessMessage(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Suceess")));
  }

  void showErrorMessage(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Some Error Occured")));
  }

 Future<void> UpdateData() async {
   final title=titleController.text;
   final description=descriptionController.text;

   final id= widget.todo!['_id'];
   final body={
     "title": title,
     "description": description,
     "is_completed": false
   };

// submit update data to server

   final isSuccess=await TodoService.updateData(id, body);
   if(isSuccess){
     showSuccessMessage();
   }else{
     showErrorMessage();
   }

 }

}

