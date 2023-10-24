import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {  
  runApp(const MaterialTodo());
}

class MaterialTodo extends StatelessWidget {
  const MaterialTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Todo App",
      debugShowCheckedModeBanner: false,
      home: Todo(),
    );
  }
}
class Todo extends StatefulWidget {
  const Todo({Key? key}) : super(key: key);

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {

  final searchcontroller=TextEditingController();
  int navigationindex=0;
  List<String> textlist=[];
  List<String> boollist=[];
  static final textcontroller=TextEditingController();


  Future<void> initcopy()async{
    final savelist=await SharedPreferences.getInstance();
    setState(() {
      var textlistcopy=savelist.getStringList("text");
      var boollistcopy=savelist.getStringList("bool");
      if (textlistcopy!=null && boollistcopy!=null) {
        textlist=textlistcopy;
        boollist=boollistcopy;
      }else{
        textlist=["Get Started"];
        boollist=["f"];
      }
      if(textlist==[] && boollist==[]){textlist=["Get Started"];boollist=["f"];}
    });
  }

  @override
  void initState() {
    initcopy();
    super.initState();
  }

  Future<void> update()async{
      final savelist=await SharedPreferences.getInstance();
      await savelist.setStringList("text", textlist);
      await savelist.setStringList("bool",boollist);
      setState(() {textlist=textlist;boollist=boollist;});
  }

  Widget buildtodo(int index){
    final String textvalue=textlist[index];
    bool menumatches=false;
    if ((boollist[index]=="f" && navigationindex==2)||(boollist[index]=="t" && navigationindex==1)||(navigationindex==0)){menumatches=true;}
    return Visibility(
      visible: textvalue.contains(searchcontroller.text) && menumatches?true:false,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: const Color.fromARGB(255, 208, 208, 208),),
          width: MediaQuery.of(context).size.width,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            IconButton(icon: boollist[index]=="t"?const Icon(Icons.check_box):const Icon(Icons.check_box_outline_blank),onPressed:(){setState(() {
              if (boollist[index]=="t"){boollist[index]="f";}else{boollist[index]="t";}
              update();
            });} ,hoverColor: Colors.transparent,),
            boollist[index]=="t" ? Text(textlist[index], style: const TextStyle(color: Colors.grey),):Text(textlist[index],),
            IconButton(icon: const Icon(Icons.delete),onPressed:(){setState(() {
              boollist.removeAt(index);
              textlist.removeAt(index);
              update();
            });} ,hoverColor: Colors.transparent,),
          ],),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 3, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly  ,
              children: [


                Expanded(
                  flex: 10,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: const Color.fromARGB(179, 236, 236, 236)),
                    width: 40,
                    padding: const EdgeInsets.fromLTRB(5, 3, 2, 0),
                    child: TextField(
                      onChanged: ((value) => setState(() {})),
                      cursorColor: Colors.black,
                      controller: searchcontroller,
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        suffixIcon: textcontroller.text==""?IconButton(
                          onPressed:() {setState(() {});},
                          icon:const Icon(Icons.search),
                          color: Colors.black,
                          hoverColor: Colors.transparent,)
                        :IconButton(
                          onPressed:() {setState((){searchcontroller.clear();});},
                          icon:const Icon(Icons.close),
                          color: Colors.black,
                          hoverColor: Colors.transparent,)
                      ),
                    ),
                  ),
                ),


                Expanded(
                  flex: 2,
                  child: IconButton(
                    icon: const Icon(Icons.add,size: 25.0,),
                    onPressed: () {
                      setState(() {
                        showDialog(context: context, builder: ((BuildContext context) {
                          return SimpleDialog(
                            title: const Text("New To-Do"),
                            children: <Widget>[
                              TextField(
                                autofocus: true,
                                controller: textcontroller,
                                decoration: const InputDecoration(hintText: "Name"),  
                              ),
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: const Text("Cancel")),
                              TextButton(onPressed: (){
                                setState(() {
                                  textlist.add(textcontroller.text);
                                  boollist.add("f"); 
                                  textcontroller.clear();
                                  update();

                                });
                                Navigator.pop(context);
                              }, child: const Text("Add"))

                            ],
                          );
                        }));
                      });
                    },
                  ),
                 )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: textlist.length ,
              itemBuilder: (context, index) {
                return buildtodo(index);
              },
            ),
          ),

          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home),label: "All"),
              BottomNavigationBarItem(icon: Icon(Icons.done),label: "Finished"),
              BottomNavigationBarItem(icon: Icon(Icons.close),label:"Pending"),
            ],

            currentIndex: navigationindex,
            onTap: (value) => setState(() {
               navigationindex=value;
            })
           )

        ],
      ),
    );
  }
}
