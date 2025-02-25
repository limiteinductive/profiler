import {PlatformLocation} from '@angular/common';
import {HttpClient, HttpParams} from '@angular/common/http';
import {Injectable} from '@angular/core';
import {API_PREFIX, DATA_API, LOCAL_URL, PLUGIN_NAME} from 'org_xprof/frontend/app/common/constants/constants';
import {DataTable} from 'org_xprof/frontend/app/common/interfaces/data_table';
import {DataServiceV2Interface} from 'org_xprof/frontend/app/services/data_service_v2/data_service_v2_interface';
import {Observable} from 'rxjs';

/** The data service class that calls API and return response. */
@Injectable()
export class DataServiceV2 implements DataServiceV2Interface {
  isLocalDevelopment = false;
  pathPrefix = '';
  searchParams?: URLSearchParams;

  constructor(
      private readonly httpClient: HttpClient,
      platformLocation: PlatformLocation) {
    this.isLocalDevelopment = platformLocation.pathname === LOCAL_URL;
    if (String(platformLocation.pathname).includes(API_PREFIX + PLUGIN_NAME)) {
      this.pathPrefix =
          String(platformLocation.pathname).split(API_PREFIX + PLUGIN_NAME)[0];
    }
    this.searchParams = new URLSearchParams(window.location.search);
  }

  getData(
      sessionId: string, tool: string, host: string,
      parameters: Map<string, string> = new Map()): Observable<DataTable|null> {
    const params = new HttpParams()
                       .set('run', sessionId)
                       .set('tag', tool)
                       .set('host', host);
    parameters.forEach((value, key) => {
      params.set(key, value);
    });
    return this.httpClient.get(this.pathPrefix + DATA_API, {params}) as
        Observable<DataTable>;
  }
}
