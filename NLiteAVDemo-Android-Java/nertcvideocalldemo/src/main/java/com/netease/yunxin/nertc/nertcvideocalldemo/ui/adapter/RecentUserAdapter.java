package com.netease.yunxin.nertc.nertcvideocalldemo.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.netease.videocall.demo.videocall.R;
import com.netease.yunxin.nertc.login.model.ProfileManager;
import com.netease.yunxin.nertc.login.model.UserModel;
import com.netease.yunxin.nertc.nertcvideocalldemo.ui.NERTCVideoCallActivity;

import java.util.List;

public class RecentUserAdapter extends RecyclerView.Adapter<RecentUserAdapter.ViewHolder> {

    private List<UserModel> mUsers;

    private Context mContext;

    //创建ViewHolder
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public ImageView ivUser;

        public ViewHolder(View v) {
            super(v);
            ivUser = v.findViewById(R.id.iv_user);
        }
    }

    public RecentUserAdapter(List<UserModel> users, Context context) {
        this.mUsers = users;
        this.mContext = context;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (mUsers != null) {
            Glide.with(mContext).load(mUsers.get(position).avatar).apply(RequestOptions.bitmapTransform(new RoundedCorners(7))).into(holder.ivUser);
            holder.itemView.setOnClickListener(view -> {
                UserModel currentUser = ProfileManager.getInstance().getUserModel();
                if (currentUser == null|| TextUtils.isEmpty(currentUser.imAccid)){
                    Toast.makeText(mContext,"当前用户登录存在问题，请注销后重新登录",Toast.LENGTH_SHORT).show();
                    return;
                }
                UserModel searchedUser = mUsers.get(position);
                if (currentUser.imAccid.equals(searchedUser.imAccid)||currentUser.mobile.equals(searchedUser.mobile)) {
                    Toast.makeText(mContext, "不能呼叫自己！", Toast.LENGTH_SHORT).show();
                    return;
                }
                NERTCVideoCallActivity.startCallOther(mContext, searchedUser);
            });
        }
    }

    @Override
    public int getItemCount() {
        return mUsers == null ? 0 : mUsers.size();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.user_item_layout, parent, false);
        return new ViewHolder(v);
    }


}
