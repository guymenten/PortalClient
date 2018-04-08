package widgets;
import db.DBHistory;
import db.DBTranslations;
import enums.Enums.MinMax;
import util.PlotGraph;

/**
 * ...
 * @author GM
 */
class WPlotStatistics extends WBase
{
	var plotsArray:Array<PlotGraph>;
	var maxY:Float;
	var minY:Float;

	/**
	 * 
	 * @param	name
	 */
	public function new(name:String) 
	{
		super(name);

		createPlotsArray();
	}

	/**
	 * 
	 */
	function createPlotsArray() 
	{
		plotsArray		= new Array<PlotGraph>();
		var index:Int 	= 0;
		var plotGraph:PlotGraph;

		for (channel in Model.channelsArray)
		{
			plotGraph 			= new PlotGraph();
			plotGraph.setLabels(DBTranslations.getText("IDS_TIME"), DBTranslations.getText("IDS_CPS"));

			plotGraph.setPlotColor(channel.plotColor, channel.channelIndex);
			plotsArray.push(plotGraph);
		}
	}

	/**
	 * 
	 */
	public function eraseValues():Void
	{
		var index:Int = 0;

		for (channel in Model.channelsArray)
		{
			plotsArray[index].eraseValues();
		}
	}

	/**
	 * 
	 */
	public function update():Void
	{
		var index:Int 			= 0;
		var minmax:MinMax 		= new MinMax();
		var values:Int 			= 0;

		for (channel in Model.channelsArray)
		{
			var graph:PlotGraph = plotsArray[index];

			graph.eraseValues();
			minmax = fitData(index, cast graph.width, minmax);

			index ++;
		}

		index = 0;

		for (channel in Model.channelsArray)
		{
			var graph:PlotGraph = plotsArray[index];
			graph.setXRange(0, graph.getCountX());
			graph.setYRange(minmax);
			graph.drawValues();
			index ++;
		}
	}

	/**
	 * 
	 * @param	index
	 */
	function fitData(indexIn:Int, valuesIn:Int, minmax:MinMax) : MinMax
	{
		var time			= 0;
		var values			= 0;
		var totValues:Float	= cast DBHistory.historyArray.length;
		var dX				= valuesIn / totValues;
		var index:Float		= 0;
		var delta:Float		= (valuesIn > totValues) ? 1 : 1/dX;

		for (data in DBHistory.historyArray)
		{
			if (data.channel == indexIn + 1)
			{
				minmax.setvalue( data.noise);
				pushValue(indexIn, cast time ++, data.noise);
			}
		}

		return minmax;
	}

	/**
	 * 
	 */
	public function pushValue(index:Int, timeIn:Int, noiseIn:Int, autoRange:Bool = true):Void
	{
		if (noiseIn > 3000) noiseIn = 3000;
		plotsArray[index].pushValue(timeIn, noiseIn, true);
	}

	/**
	 * 
	 * @param	float
	 * @param	float1
	 * @param	float2
	 * @param	float3
	 */
	public function init(w:Int, h:Int, xScale:Int, yScale:Int) 
	{
		trace("init");
		var index = 0;
		var graph:PlotGraph;
		var array:Array<String> = new Array<String>();
		array.push("");

		for (channel in Model.channelsArray)
		{
			graph = plotsArray[index];
			addChild(graph);
			graph.init(0, 0, w, h, index != 0); // First plot is normal, others are overlays
			array.push(channel.label);

			graph.drawValues();
			index ++;
		}

		plotsArray[0].setTitle(array);
	}
}