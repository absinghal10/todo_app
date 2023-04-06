import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/services/todo_services.dart';
import 'package:todo_app/widgets/todo_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List items=[];
  bool isLoading=true;
  @override
  void initState() {
    super.initState();
    fetchTodotask();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed:(){
        navigateToAddPage();
      },
          icon: Icon(Icons.add),
          label: Text('Add Todo')),

      body: Visibility(
        visible: isLoading,
        child : Center(child: CircularProgressIndicator()),
        replacement : RefreshIndicator(
          onRefresh: fetchTodotask,
          child: Visibility(
              visible: items.isNotEmpty,
            replacement: Center(child: Text('No Todo Item',style: Theme.of(context).textTheme.headlineMedium,),),
            child: ListView.builder(itemBuilder: (context, index)
            {
              final item=items[index] as Map;
              final String id=item['_id'];
              return TodoCard(index: index, item: item, navigateEdit: navigateToEditPage, deletebyId: deleteTaskbyId);
            },
            itemCount: items.length,
              padding: EdgeInsets.all(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> navigateToAddPage() async{
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage(),));
    setState(() {
      isLoading=true;
    });
    fetchTodotask();
  }

  Future<void> navigateToEditPage(Map item) async {
   await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage(todo:item),));
   setState(() {
     isLoading=true;
   });
   fetchTodotask();

  }

  Future<void> fetchTodotask() async {

    final response= await TodoService().fetchTodo();
    if(response!=null) {
      setState(() {
        items=response;
      });

    }else{
    showErrorMessage();
   }
      setState(() {
        isLoading=false;
      });
      showSuccessMessage();
  }

  void showSuccessMessage(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Suceess")));
  }

  void showErrorMessage(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Some Error Occured")));
  }

  Future<void> deleteTaskbyId(String id) async {
   
    final isSuccess=await TodoService.deleteById(id);

    if(isSuccess){
      // remove item from list
      final flitered=items.where((element) => element['_id']!=id).toList();

      setState(() {
        items=flitered;
      });
      showSuccessMessage();
    }else{
      showErrorMessage();
    }

  }

}
