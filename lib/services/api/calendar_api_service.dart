import 'api_client.dart';


class CalendarDay {

  final String date;

  final int taskCount;

  final int completedCount;

  final double completionRate;

  final bool hasReflection;


  CalendarDay({
    required this.date,
    required this.taskCount,
    required this.completedCount,
    required this.completionRate,
    required this.hasReflection,
  });


  factory CalendarDay.fromMap(
    Map<String,dynamic> data,
  ){

    return CalendarDay(

      date:
          data['date']
              ?.toString()
              ??
              '',


      taskCount:
          _toInt(
            data['task_count'],
          ),


      completedCount:
          _toInt(
            data['completed_count'],
          ),


      completionRate:
          _toDouble(
            data['completion_rate'],
          ),


      hasReflection:
          data['has_reflection']==true ||
          data['has_reflection']==1,

    );

  }



  static int _toInt(dynamic value){

    if(value is int){
      return value;
    }


    if(value is num){
      return value.toInt();
    }


    return int.tryParse(
      value?.toString() ?? '',
    ) ?? 0;

  }



  static double _toDouble(dynamic value){

    if(value is double){
      return value;
    }


    if(value is num){
      return value.toDouble();
    }


    return double.tryParse(
      value?.toString() ?? '',
    ) ?? 0.0;

  }

}





class CalendarApiService {


  final ApiClient apiClient;


  CalendarApiService(
    this.apiClient,
  );



  Future<List<CalendarDay>> getCalendar() async {


    final response =
        await apiClient.get(
          '/api/calendar/',
        );


    final data =
        response['data'];



    if(data is! List){

      return [];

    }



    return data
        .whereType<Map>()
        .map(
          (item)=>
              CalendarDay.fromMap(
                Map<String,dynamic>.from(
                  item,
                ),
              ),
        )
        .toList();

  }




  Future<int> getStreak(String date) async {


    final response =
        await apiClient.get(
          '/api/calendar/streak?date=$date',
        );


    final data =
        response['data'];



    if(data is Map){

      return CalendarDay._toInt(
        data['streak'],
      );

    }



    return CalendarDay._toInt(
      response['streak'],
    );

  }

}