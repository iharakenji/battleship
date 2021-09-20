import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

void main() => runApp(BattleshipApp());

class BattleshipApp extends StatelessWidget {
  final int rows, columns;

  const BattleshipApp({this.columns = 10, this.rows = 10});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('BattleshipPuzzle'),
          ),
          body: _BattleshipHome(rows, columns),
        ),
      );
}

class _BattleshipHome extends StatefulWidget {
  final int _rows, _columns;

  const _BattleshipHome(this._rows, this._columns);

  @override
  _BattleshipHomeState createState() => _BattleshipHomeState(_columns, _rows);
}

class _BattleshipHomeState extends State<_BattleshipHome> {
  final int _rows, _columns;
  var _tapCount = 0;
  late List<List<CellType>> _cellTypes;
  late List<List<bool>> _tapped;

  _BattleshipHomeState(this._rows, this._columns);

  @override
  void initState() {
    super.initState();
    _cellTypes = CellTypeGenerator.generate(_rows, _columns);
    _tapped =
        List.generate(_rows, (_) => List.generate(_columns, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer();
  }

  Widget _buildContainer() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Text('TapCount: $_tapCount'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: ElevatedButton(
              onPressed: () => _pushReset(),
              child: const Text('Reset'),
            ),
          ),
          Container(
            width: 440,
            height: 440,
            child: _buildColumn(),
          ),
        ]),
      );

  Widget _buildColumn() {
    final columns = Column(
      children: List.generate(
        _rows,
        (index) => Container(child: _buildRow(index)),
      ),
    );

    columns.children.add(Row(
        children: List.generate(_columns, (cellIndex) {
      List<CellType> _cellTypesOfCell =
          List.generate(_rows, (rowIndex) => _cellTypes[rowIndex][cellIndex]);
      return _buildShipCount(_cellTypesOfCell);
    })));

    return columns;
  }

  Widget _buildRow(int rowIndex) {
    final rows = Row(
      children: List.generate(_columns, (index) => _buildCell(rowIndex, index)),
    );
    rows.children.add(_buildShipCount(_cellTypes[rowIndex]));
    return rows;
  }

  Widget _buildCell(int rowIndex, int columnIndex) {
    final cellType = _cellTypes[rowIndex][columnIndex];
    final alreadyTapped = _tapped[rowIndex][columnIndex];

    final cell = GestureDetector(
      onTap: () => setState(() {
        if (cellType == CellType.Wave) {
        } else if (alreadyTapped) {
        } else {
          _tapCount++;
          _tapped[rowIndex][columnIndex] = true;
        }
      }),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: _buildCellCentent(cellType, alreadyTapped),
      ),
    );
    return cell;
  }

  Widget _buildCellCentent(CellType cellType, bool alreadyTapped) {
    if (alreadyTapped) {
      switch (cellType) {
        case CellType.Wave:
          return Icon(Icons.waves);
        case CellType.None:
          return Icon(Icons.check);
        case CellType.ShipCircle:
          return Container(
            margin: EdgeInsets.all(5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          );
        case CellType.ShipSquare:
          return Container(
            margin: EdgeInsets.all(5),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.black,
            ),
          );
        case CellType.ShipRoundTop:
          return Container(
            margin: EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              color: Colors.black,
            ),
          );
        case CellType.ShipRoundLeft:
          return Container(
            margin: EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
              ),
              color: Colors.black,
            ),
          );
        case CellType.ShipRoundBottom:
          return Container(
            margin: EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              color: Colors.black,
            ),
          );
        case CellType.ShipRoundRight:
          return Container(
            margin: EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              color: Colors.black,
            ),
          );
        default:
          return Container();
      }
    } else {
      switch (cellType) {
        case CellType.Wave:
          return Icon(Icons.waves);
        default:
          return Container();
      }
    }
  }

  Widget _buildShipCount(List<CellType> cellTypes) {
    final shipCount = cellTypes.where((cellType) {
      switch (cellType) {
        case CellType.ShipCircle:
        case CellType.ShipSquare:
        case CellType.ShipRoundTop:
        case CellType.ShipRoundLeft:
        case CellType.ShipRoundBottom:
        case CellType.ShipRoundRight:
          return true;
        default:
          return false;
      }
    }).length;

    return Container(
      width: 40,
      height: 40,
      child: Center(
          child:
              Text(shipCount.toString(), style: const TextStyle(fontSize: 18))),
    );
  }

  void _pushReset() {
    setState(() {
      _tapCount = 0;
      _cellTypes = CellTypeGenerator.generate(_rows, _columns);
      for (var i = 0; i < _rows; i++) {
        for (var j = 0; j < _columns; j++) {
          _tapped[i][j] = false;
        }
      }
    });
  }
}

class CellTypeGenerator {
  static const ship1 = Ship(1, 4);
  static const ship2 = Ship(2, 3);
  static const ship3 = Ship(3, 2);
  static const ship4 = Ship(4, 1);
  static const wave = 2;

  static List<List<CellType>> generate(int rows, int columns) {
    var cellTypes = List.generate(
        rows, (_) => List.generate(columns, (_) => CellType.None));

    var ships = [ship4, ship3, ship2, ship1];
    for (var ship in ships) {
      cellTypes = placeShip(cellTypes, ship, rows, columns);
    }
    cellTypes = placeWave(cellTypes, rows, columns);

    return cellTypes;
  }

  static List<List<CellType>> placeShip(List<List<CellType>> cellTypes, Ship ship, int rows, int columns) {
    for (var numIndex = 0; numIndex < ship.num; numIndex++) {
      var positions = buildPositions(cellTypes, ship, rows, columns);
      if (positions.isEmpty) {
        continue;
      }
      var position = positions[Random().nextInt(positions.length)];
      if (ship.size == 1) {
        cellTypes[position.item2][position.item3] = CellType.ShipCircle;
      } else if (position.item1 == Direction.Horizontal) {
        cellTypes[position.item2][position.item3] = CellType.ShipRoundLeft;
        for (var sizeIndex = 1; sizeIndex < ship.size; sizeIndex++) {
          cellTypes[position.item2][position.item3 + sizeIndex] =
              CellType.ShipSquare;
        }
        cellTypes[position.item2][position.item3 + ship.size - 1] =
            CellType.ShipRoundRight;
      } else {
        cellTypes[position.item2][position.item3] = CellType.ShipRoundTop;
        for (var sizeIndex = 1; sizeIndex < ship.size; sizeIndex++) {
          cellTypes[position.item2 + sizeIndex][position.item3] =
              CellType.ShipSquare;
        }
        cellTypes[position.item2 + ship.size - 1][position.item3] =
            CellType.ShipRoundBottom;
      }
    }
    return cellTypes;
  }

  static List<List<CellType>> placeWave(List<List<CellType>> cellTypes, int rows, int columns) {
    for (var i = 0; i < wave; i++) {
      List<Tuple2<int, int>> positions = [];
      for (var row = 0; row < rows; row++) {
        for (var column = 0; column < columns; column++) {
          if (cellTypes[row][column] == CellType.None) {
            positions.add(Tuple2(row, column));
          }
        }
      }
      var position = positions[Random().nextInt(positions.length)];
      cellTypes[position.item1][position.item2] = CellType.Wave;
    }
    return cellTypes;
  }

  static List<Tuple3<Direction, int, int>> buildPositions(List<List<CellType>> cellTypes, Ship ship, int rows, int columns) {
    List<Tuple3<Direction, int, int>> positions = [];
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        if (canExistsHorizontal(
            cellTypes, ship, rows, row, columns, column)) {
          positions.add(Tuple3(Direction.Horizontal, row, column));
        }
        if (canExistsVertical(
            cellTypes, ship, rows, row, columns, column)) {
          positions.add(Tuple3(Direction.Vertical, row, column));
        }
      }
    }
    return positions;
  }

  static bool canExistsHorizontal(List<List<CellType>> cellTypes, Ship ship,
      int rows, int row, int columns, int column) {
    if (columns < column + ship.size) {
      return false;
    }
    // 左側チェック
    if (0 < column) {
      if (0 < row && cellTypes[row - 1][column - 1] != CellType.None) {
        return false;
      }
      if (cellTypes[row][column - 1] != CellType.None) {
        return false;
      }
      if (row + 1 < rows && cellTypes[row + 1][column - 1] != CellType.None) {
        return false;
      }
    }
    // 右側チェック
    if (column + ship.size < columns) {
      if (0 < row && cellTypes[row - 1][column + 1] != CellType.None) {
        return false;
      }
      if (cellTypes[row][column + 1] != CellType.None) {
        return false;
      }
      if (row + 1 < rows && cellTypes[row + 1][column + 1] != CellType.None) {
        return false;
      }
    }
    // 真ん中チェック
    for (var sizeIndex = 0; sizeIndex < ship.size; sizeIndex++) {
      if (0 < row && cellTypes[row - 1][column + sizeIndex] != CellType.None) {
        return false;
      }
      if (cellTypes[row][column + sizeIndex] != CellType.None) {
        return false;
      }
      if (row + 1 < rows &&
          cellTypes[row + 1][column + sizeIndex] != CellType.None) {
        return false;
      }
    }
    return true;
  }

  static bool canExistsVertical(List<List<CellType>> cellTypes, Ship ship,
      int rows, int row, int columns, int column) {
    if (rows < row + ship.size) {
      return false;
    }
    // 上側チェック
    if (0 < row) {
      if (0 < column && cellTypes[row - 1][column - 1] != CellType.None) {
        return false;
      }
      if (cellTypes[row - 1][column] != CellType.None) {
        return false;
      }
      if (column + 1 < columns &&
          cellTypes[row - 1][column + 1] != CellType.None) {
        return false;
      }
    }
    // 下側チェック
    if (row + ship.size < rows) {
      if (0 < column && cellTypes[row + 1][column - 1] != CellType.None) {
        return false;
      }
      if (cellTypes[row + 1][column] != CellType.None) {
        return false;
      }
      if (column + 1 < columns &&
          cellTypes[row + 1][column + 1] != CellType.None) {
        return false;
      }
    }
    // 真ん中チェック
    for (var sizeIndex = 0; sizeIndex < ship.size; sizeIndex++) {
      if (0 < column &&
          cellTypes[row + sizeIndex][column - 1] != CellType.None) {
        return false;
      }
      if (cellTypes[row + sizeIndex][column] != CellType.None) {
        return false;
      }
      if (column + 1 < columns &&
          cellTypes[row + sizeIndex][column + 1] != CellType.None) {
        return false;
      }
    }
    return true;
  }
}

class Ship {
  final int size, num;

  const Ship(this.size, this.num);
}

enum CellType {
  Wave,
  None,
  ShipCircle,
  ShipSquare,
  ShipRoundTop,
  ShipRoundLeft,
  ShipRoundBottom,
  ShipRoundRight,
}

enum Direction {
  Vertical,
  Horizontal,
}
