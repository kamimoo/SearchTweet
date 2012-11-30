package my.searchtweet

import android.content.Context
import android.net.Uri
import android.util.Log
import android.support.v4.content.AsyncTaskLoader

import org.apache.http.HttpResponse
import org.apache.http.HttpStatus
import org.apache.http.client.HttpClient
import org.apache.http.client.methods.HttpGet
import org.apache.http.impl.client.DefaultHttpClient
import org.apache.http.util.EntityUtils

import org.json.JSONException
import org.json.JSONObject

import java.io.IOException

class TweetsLoader extends AsyncTaskLoader<JSONObject> { 
	String q
	JSONObject result
	val TAG = getClass().simpleName
	
	new(Context context, String q) {
		super(context)
		this.q = q
	}

	override loadInBackground() {
		var builder = new Uri$Builder
		builder.scheme("http")
		.encodedAuthority("search.twitter.com")
		.path("/search.json")
		.appendQueryParameter("q", q)
		
		var HttpClient client = new DefaultHttpClient
		var String content
		
		try {
			var HttpGet httpGet = new HttpGet(builder.build.toString)
			content = client.execute(httpGet, [HttpResponse response|
				if (response.statusLine.statusCode == HttpStatus::SC_OK) {
					return EntityUtils::toString(response.entity)
				}
			])
			return new JSONObject(content)
				
		} catch (IOException e) {
			
		} catch (JSONException e) {
			Log::e(TAG, "invalid response:" + content, e)
		}
		return null
	}
	
	override deliverResult(JSONObject data) {
		if (isReset) {
			if (result != null) {
				result = null;
			}
			return
		}
		
		result = data
		if (isStarted) {
			super.deliverResult(data)
		}
	}
	
	override onStartLoading() {
		if (result != null) {
			deliverResult(result)
		}
		if (takeContentChanged || result == null) {
			forceLoad
		}
	}
	
	override onStopLoading() {
		super.onStopLoading
		cancelLoad
	}
	
	override onReset() {
		super.onReset
		onStopLoading
	}
	
}