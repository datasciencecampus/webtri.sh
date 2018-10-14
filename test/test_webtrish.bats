#!/usr/bin/env bats

source "webtri.sh"


@test "get_area 1" {

  curl()
  {
    cat << EOF
    {
      "row_count": 1,
      "areas": [
        {
          "Id": "1",
          "Name": "lala",
          "Description": "descr",
          "XLongitude": "-1.123",
          "XLatitude": "53.123",
          "YLongitude": "-1.55",
          "YLatitude": "54.1"
        }
      ]
    }
EOF
  }

  run get_area 1

  echo "result = $output"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "id,name,description,x_lon,x_lat,y_lon,y_lat" ]
  [ "${lines[1]}" = "1,lala,descr,-1.123,53.123,-1.55,54.1" ]
}

@test "get_area" {

  curl()
  {
    cat << EOF
    {
      "row_count": 2,
      "areas": [
        {
          "Id": "1",
          "Name": "lala",
          "Description": "descr",
          "XLongitude": "-1.123",
          "XLatitude": "53.123",
          "YLongitude": "-1.55",
          "YLatitude": "54.1"
        },
        {
          "Id": "2",
          "Name": "heh",
          "Description": "x",
          "XLongitude": "1",
          "XLatitude": "2",
          "YLongitude": "3",
          "YLatitude": "4"
        }
      ]
    }
EOF
  }

  run get_area

  echo "result = $output"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "id,name,description,x_lon,x_lat,y_lon,y_lat" ]
  [ "${lines[1]}" = "1,lala,descr,-1.123,53.123,-1.55,54.1" ]
  [ "${lines[2]}" = "2,heh,x,1,2,3,4" ]
}

@test "get_quality 5688 01012018 04012018 daily" {

  curl()
  {
    cat << EOF
    {
      "row_count": 4,
      "Qualities": [
      {
        "Date": "2018-01-01T00:00:00",
        "Quality": 100
      },
      {
        "Date": "2018-01-02T00:00:00",
        "Quality": 100
      },
      {
        "Date": "2018-01-03T00:00:00",
        "Quality": 100
      },
      {
        "Date": "2018-01-04T00:00:00",
        "Quality": 100
      }
      ]
    }
EOF
  }

  run get_quality 5688 01012018 04012018 daily

  echo "result = $output"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "date,quality" ]
  [ "${lines[1]}" = "2018-01-01T00:00:00,100" ]
  [ "${lines[2]}" = "2018-01-02T00:00:00,100" ]
  [ "${lines[3]}" = "2018-01-03T00:00:00,100" ]
  [ "${lines[4]}" = "2018-01-04T00:00:00,100" ]

}

@test "get_quality 5688,5699 01012018 04012018 overall" {

  curl()
  {
    cat << EOF
    {
      "row_count": 1,
      "start_date": "01012018",
      "end_date": "04012018",
      "data_quality": 67,
      "sites": "5688,5699"
    }
EOF
  }

  run get_quality 5688,5699 01012018 04012018 overall
  
  echo "result = $output"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "quality" ]

  # note that remote will actually return 67 due to bug.
  # client corrects for this.
  [ "${lines[1]}" = "50" ]
}

@test "get_report 5688 Daily 01012015 01012018" {

}

@test "get_report 5688 daily 01012018 01012018" {

}

@test "get_sites" {

}

@test "get_sites 5688" {

}

@test "get_sites 5688,5689" {

}

@test "get_site_by_type 1" {

}

@test "get_site_by_type" {

  # intercept curl call, return mock.
  curl()
  {
    cat << EOF
    {
      "row_count": 4,
      "sitetypes": [
        {
          "Id": "1",
          "Description": "MIDAS"
        },
        {
          "Id": "2",
          "Description": "TAME"
        },
        {
          "Id": "3",
          "Description": "TMU"
        },
        {
          "Id": "4",
          "Description": "Legacy"
        }
      ]
    }
EOF
  }

  expected=$(cat << EOF
id,description
1,MIDAS
2,TAME
3,TMU
4,Legacy
EOF
)

  run get_site_by_type

  echo "result = $output"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}
