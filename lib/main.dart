import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

void main() => runApp(BattleshipApp());

class BattleshipApp extends StatelessWidget {
  final int rows, columns, waves;
  late final List<Ship> ships;

  BattleshipApp({this.columns = 10, this.rows = 10, this.waves = 2}) {
    ships = [
      const Ship(4, 1),
      const Ship(3, 2),
      const Ship(2, 3),
      const Ship(1, 4)
    ];
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('BattleshipPuzzle'),
          ),
          body: _BattleshipHome(rows, columns, ships, waves),
        ),
      );
}

class _BattleshipHome extends StatefulWidget {
  final int _rows, _columns, _waves;
  final List<Ship> _ships;

  const _BattleshipHome(this._rows, this._columns, this._ships, this._waves);

  @override
  _BattleshipHomeState createState() =>
      _BattleshipHomeState(_columns, _rows, _ships, _waves);
}

class _BattleshipHomeState extends State<_BattleshipHome> {
  final int _rows, _columns, _waves;
  final List<Ship> _ships;
  var _tapCount = 0;
  late int _remainCount;
  late List<List<CellType>> _cellTypes;
  late List<List<bool>> _tapped;

  _BattleshipHomeState(this._rows, this._columns, this._ships, this._waves);

  @override
  void initState() {
    super.initState();
    _remainCount = _ships
        .map((e) => e.size * e.num)
        .reduce((value, element) => value + element);
    _cellTypes = _CellTypeGenerator(_rows, _columns, _ships, _waves).generate();
    _tapped =
        List.generate(_rows, (_) => List.generate(_columns, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer();
  }

  Widget _buildContainer() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () => _pushReset(),
              child: const Text('Reset'),
            ),
            const SizedBox(width: 20),
            Text('TapCount: $_tapCount'),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: 440,
            height: 440,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    child: _buildClearText(),
                  ),
                ),
                _buildColumn(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: _buildBottom(),
          ),
        ]),
      );

  Widget? _buildClearText() {
    if (_remainCount == 0) {
      return Text(
        "Clear!!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 50.0,
          color: Colors.pink[500],
        ),
      );
    } else {
      return null;
    }
  }

  Widget _buildColumn() {
    final columns = Column(
      children: List.generate(
        _rows,
        (index) => _buildRow(index),
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
          return;
        } else if (alreadyTapped) {
          return;
        } else {
          _tapCount++;
          _tapped[rowIndex][columnIndex] = true;
          if (cellType != CellType.None) {
            _remainCount--;
          }
        }
      }),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: _buildCellContent(cellType, alreadyTapped),
      ),
    );
    return cell;
  }

  Widget _buildCellContent(CellType cellType, bool alreadyTapped) {
    if (alreadyTapped) {
      switch (cellType) {
        case CellType.Wave:
          return const Icon(Icons.waves);
        case CellType.None:
          return const Icon(Icons.check);
        case CellType.ShipCircle:
          return _buildShipCircle();
        case CellType.ShipSquare:
          return _buildShipSquare();
        case CellType.ShipRoundTop:
          return _buildShipRoundTop();
        case CellType.ShipRoundLeft:
          return _buildShipRoundLeft();
        case CellType.ShipRoundBottom:
          return _buildShipRoundBottom();
        case CellType.ShipRoundRight:
          return _buildShipRoundRight();
        default:
          return Container();
      }
    } else {
      switch (cellType) {
        case CellType.Wave:
          return const Icon(Icons.waves);
        default:
          return Container();
      }
    }
  }

  Widget _buildShipCircle() {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
    );
  }

  Widget _buildShipSquare() {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.black,
      ),
    );
  }

  Widget _buildShipRoundTop() {
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
  }

  Widget _buildShipRoundLeft() {
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
  }

  Widget _buildShipRoundBottom() {
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
  }

  Widget _buildShipRoundRight() {
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

  Widget _buildBottom() {
    final column = Column(
        children:
            List.generate(_ships.length, (index) => _buildShips(_ships[index])));
    return SizedBox(
      width: 440,
      height: 160,
      child: column,
    );
  }

  Widget _buildShips(Ship ship) {
    return Row(
      children: List.generate(ship.num, (index) => _buildShip(ship.size)),
    );
  }

  Widget _buildShip(int size) {
    if (size == 1) {
      return SizedBox(
        width: 40,
        height: 40,
        child: _buildShipCircle(),
      );
    } else {
      List<Widget> row = [];
      row.add(
        SizedBox(
          width: 40,
          height: 40,
          child: _buildShipRoundLeft(),
        ),
      );
      for (var sizeIndex = 2; sizeIndex < size; sizeIndex++) {
        row.add(
          SizedBox(
            width: 40,
            height: 40,
            child: _buildShipSquare(),
          ),
        );
      }
      row.add(
        SizedBox(
          width: 40,
          height: 40,
          child: _buildShipRoundRight(),
        ),
      );
      return SizedBox(
        width: size * 40,
        height: 40,
        child: Row(children: row),
      );
    }
  }

  void _pushReset() {
    setState(() {
      _tapCount = 0;
      _remainCount = _ships
          .map((e) => e.size * e.num)
          .reduce((value, element) => value + element);
      _cellTypes =
          _CellTypeGenerator(_rows, _columns, _ships, _waves).generate();
      for (var i = 0; i < _rows; i++) {
        for (var j = 0; j < _columns; j++) {
          _tapped[i][j] = false;
        }
      }
    });
  }
}

class _CellTypeGenerator {
  final int _rows, _columns, _waves;
  final List<Ship> _ships;

  _CellTypeGenerator(this._rows, this._columns, this._ships, this._waves);

  List<List<CellType>> generate() {
    var cellTypes = List.generate(
        _rows, (_) => List.generate(_columns, (_) => CellType.None));

    for (var ship in _ships) {
      cellTypes = placeShip(cellTypes, ship);
    }
    cellTypes = placeWave(cellTypes);

    return cellTypes;
  }

  List<List<CellType>> placeShip(List<List<CellType>> cellTypes, Ship ship) {
    for (var numIndex = 0; numIndex < ship.num; numIndex++) {
      var positions = buildPositions(cellTypes, ship);
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

  List<List<CellType>> placeWave(List<List<CellType>> cellTypes) {
    for (var i = 0; i < _waves; i++) {
      List<Tuple2<int, int>> positions = [];
      for (var row = 0; row < _rows; row++) {
        for (var column = 0; column < _columns; column++) {
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

  List<Tuple3<Direction, int, int>> buildPositions(
      List<List<CellType>> cellTypes, Ship ship) {
    List<Tuple3<Direction, int, int>> positions = [];
    for (var row = 0; row < _rows; row++) {
      for (var column = 0; column < _columns; column++) {
        if (canExistsHorizontal(cellTypes, ship, row, column)) {
          positions.add(Tuple3(Direction.Horizontal, row, column));
        }
        if (canExistsVertical(cellTypes, ship, row, column)) {
          positions.add(Tuple3(Direction.Vertical, row, column));
        }
      }
    }
    return positions;
  }

  bool canExistsHorizontal(
      List<List<CellType>> cellTypes, Ship ship, int row, int column) {
    if (_columns < column + ship.size) {
      return false;
    }
    // 上下チェック
    for (var i = column - 1; i <= column + ship.size; i++) {
      if (i < 0 || _columns <= i) {
        continue;
      }
      if (0 < row && cellTypes[row - 1][i] != CellType.None) {
        return false;
      }
      if (cellTypes[row][i] != CellType.None) {
        return false;
      }
      if (row + 1 < _rows && cellTypes[row + 1][i] != CellType.None) {
        return false;
      }
    }
    return true;
  }

  bool canExistsVertical(
      List<List<CellType>> cellTypes, Ship ship, int row, int column) {
    if (_rows < row + ship.size) {
      return false;
    }
    // 左右チェック
    for (var i = row - 1; i <= row + ship.size; i++) {
      if (i < 0 || _rows <= i) {
        continue;
      }
      if (0 < column && cellTypes[i][column - 1] != CellType.None) {
        return false;
      }
      if (cellTypes[i][column] != CellType.None) {
        return false;
      }
      if (column + 1 < _columns && cellTypes[i][column + 1] != CellType.None) {
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
