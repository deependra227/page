import 'package:demo1/doctor_page.dart';
import 'package:demo1/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  
  var currentLocation ;
  List<DocumentSnapshot> doctor = [];
  double distance;
  Future getDoctor() async {
    var firestore = Firestore.instance;
      QuerySnapshot qn = await firestore.collection('Doctors').getDocuments();
      return qn.documents;
  }

  void initState(){
    super.initState();
    Geolocator().getCurrentPosition().then((currloc){
      setState((){
        print(currentLocation);
        currentLocation = currloc;
        print(currentLocation.latitude);
      }); 
    }); 
  }
  

  Widget com(buildContext,DocumentSnapshot list) => Center(
    child : AnimatedContainer(
      duration: Duration(seconds: 2),
      height :MediaQuery.of(context).size.height / 5.5,
      width : MediaQuery.of(context).size.width,
      decoration: BoxDecoration(gradient: LinearGradient(colors: kitGradients)),
      child:Material(
        child:InkWell(

    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorPage(list : list,))),
    splashColor: Colors.blue,
    child: Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Image.network(list.data['photo'], alignment: Alignment.centerLeft,),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: CircleAvatar(backgroundImage: NetworkImage(list.data['photo']),radius: 50.0,),
              ),
              Expanded(child:Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[menuData(list)],) ,)
              
            
            ],
          ),
          
        ],
      ),
    ),
        ),
      ),
    ),
    // title: list.data['docName'],
  );

// List<Menu> menu;
  static List<Color> kitGradients = [
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  // Widget menuColor() => new Container(
  //   decoration: BoxDecoration(boxShadow: <BoxShadow>[
  //     BoxShadow(
  //       color: Colors.black.withOpacity(0.8),
  //       blurRadius: 5.0,
  //     ),
  //   ]),
  // );

  Widget menuData(DocumentSnapshot list) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(height: 40.0,),
      Text(
       'Name : '+ list.data['docName'],
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20.0),
      ),
      SizedBox(height: 10.0,),
      Text(
       'Specialization  : '+ list.data['Spec'],
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      )
      
    ],
  );

  Widget appBar() =>AppBar(
    backgroundColor: Colors.black,
    // pinned: true,
    elevation: 10.0,
    // forceElevated: true,
    // expandedHeight: 20.0,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      // background: Container(
      //   decoration: BoxDecoration(
      //       gradient: LinearGradient(colors:kitGradients)),
      // ),
      title: Row(
        children: <Widget>[
          Text('Doctors')
        ],
      ),
    ),
  );


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: appBar(),
        body: FutureBuilder(future: getDoctor(),builder: (_, snapshot)
        {
          Widget newListTab;
          if(snapshot.hasData && currentLocation!=null) {


            for (int index = snapshot.data.length - 1; index >= 0; --index){     
               Geolocator().distanceBetween(currentLocation.latitude, currentLocation.longitude, snapshot.data[index].data['location'].latitude, snapshot.data[index].data['location'].longitude)
               .then((dist){
                   distance = dist;
                   print(distance);
                   if(dist/1000 > 5)
                    doctor.add(snapshot.data[index]);
                 });              
            }
            print(doctor.length);




             newListTab = ListView.builder(
               itemCount: doctor.length,
               itemBuilder: (BuildContext context,int index){
                 return com(context, doctor[index]);
               }
             );
          }
          else {
              newListTab =Column(
                
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only( top:10.0,left: 500.0),
                    )]
              );
          }
          return newListTab;
          
        //   slivers: <Widget>[
        //     appBar(),
        //     newListTab
        //   ],
        // );
      }),

      drawer:sideBar(context)


    );
  }
}

