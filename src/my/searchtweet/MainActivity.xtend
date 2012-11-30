package my.searchtweet

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.ListView
import android.widget.ArrayAdapter
import android.widget.TextView
import android.support.v4.app.FragmentActivity
import android.support.v4.app.LoaderManager
import android.support.v4.content.Loader
import android.text.TextUtils

import org.json.JSONObject

import java.util.ArrayList

class MainActivity extends FragmentActivity implements LoaderManager$LoaderCallbacks<JSONObject> {
	
	TweetAdapter mAdapter
	Button mButton
	EditText mSearchText
	
	override onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState)
		setContentView(R$layout::activity_main)
		mSearchText = findViewById(R$id::searchText) as EditText
		mButton = findViewById(R$id::button) as Button
		mButton.onClickListener = [
			var args = new Bundle
			args.putString('q', mSearchText.text.toString)
			supportLoaderManager.restartLoader(0, args, this)
		]
		var list = findViewById(R$id::list) as ListView
		mAdapter = new TweetAdapter(this, newArrayList())
		list.adapter = mAdapter
		
	}
	

	override onCreateLoader(int id, Bundle args) {
		var q = args.getString('q')
		return if (TextUtils::isEmpty(q)) {
			null
		} else {
			new TweetsLoader(this, q)
		}
	}
	
	override onLoadFinished(Loader<JSONObject> loader, JSONObject data) {
		mAdapter.clear
		var results = data.getJSONArray('results')
		for (i : 0..(results.length - 1)) {
			var tweetJSON = results.getJSONObject(i)
			mAdapter.add(new Tweet(
				tweetJSON.getString('from_user_name'),
				tweetJSON.getString('text')
			))
		}
	}
	
	override onLoaderReset(Loader<JSONObject> loader) {
	}
	
}

class TweetAdapter extends ArrayAdapter<Tweet> {
	new(Context context, ArrayList<Tweet> values) {
		super(context, R$layout::view_tweet, values)
	}
	
	override getView(int position, View convertView, ViewGroup parent) {
		var inflater = context.getSystemService(Context::LAYOUT_INFLATER_SERVICE) as LayoutInflater
		var view = inflater.inflate(R$layout::view_tweet, parent, false)
		var screenName = view.findViewById(R$id::screenName) as TextView
		var text = view.findViewById(R$id::text) as TextView
		screenName.text = getItem(position).screenName
		text.text = getItem(position).text
		view
	}
}

@Data class Tweet {
	String screenName
	String text
}