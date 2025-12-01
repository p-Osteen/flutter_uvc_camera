package com.serenegiant.utils;

import android.os.Build;

public class BuildCheck {
    public static boolean isLollipop() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP;
    }
    
    public static boolean isMarshmallow() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M;
    }
    
    public static boolean isAndroid5() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP;
    }
    
    public static boolean isAPI31() {
        return Build.VERSION.SDK_INT >= 31; // Build.VERSION_CODES.S
    }
}
